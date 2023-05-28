with RP.GPIO;
with RP.DMA;
with RP.PWM;
with RP_Interrupts;
with RP2040_SVD.Interrupts;
with RP.ROM.Floating_Point;
with Noise_Nugget_SDK.Audio.PIO_I2S_ASM;

with Interfaces;

package body Noise_Nugget_SDK.Audio.I2S is

   G_Next_Out : Boolean := False
     with Volatile, Atomic;

   type Flip_Buffers is array (Boolean) of Stereo_Buffer;

   --  In_Buffers : Flip_Buffers := (others => (others => (0, 0)));
   Out_Buffers : Flip_Buffers := (others => (others => (0, 0)));

   Sine_Buffer :  Stereo_Buffer := (others => (0, 0));

   Data_In     : RP.GPIO.GPIO_Point := (Pin => 0);
   Data_Out    : RP.GPIO.GPIO_Point := (Pin => 1);
   LRCLK       : RP.GPIO.GPIO_Point := (Pin => 2);
   BCLK        : RP.GPIO.GPIO_Point := (Pin => 3);
   MCLK        : RP.GPIO.GPIO_Point := (Pin => 4);

   DMA_IRQ     : constant RP.DMA.DMA_IRQ_Id := 0;

   Sample_Frequency : constant := 44_100;

   MCLK_Requested_Frequency : constant := 256 * Sample_Frequency;
   MCLK_PWM : constant RP.PWM.PWM_Slice := RP.PWM.To_PWM (MCLK).Slice;

   G_Callback : Audio_Callback := null;

   ---------------------
   -- DMA_Out_Handler --
   ---------------------

   procedure DMA_Out_Handler is
      To_Send     : Stereo_Buffer renames Out_Buffers (G_Next_Out);
      To_Callback : Stereo_Buffer renames Out_Buffers (not G_Next_Out);
   begin

      RP.DMA.Ack_IRQ (I2S_OUT_DMA, DMA_IRQ);

      --  RP.DMA.Start
      --    (Channel => I2S_IN_DMA,
      --     From    => RP.PIO.RX_FIFO_Address (I2S_PIO, I2S_SM),
      --     To      => In_Buffer'Address,
      --     Count   => In_Buffer'Length);

      RP.DMA.Start
        (Channel => I2S_OUT_DMA,
         From    => To_Send'Address,
         To      => RP.PIO.TX_FIFO_Address (I2S_PIO, I2S_SM),
         Count   => To_Send'Length);

      if G_Callback /= null then
         G_Callback.all (To_Callback);
      else
         To_Callback := Sine_Buffer;
      end if;

      G_Next_Out := not G_Next_Out;
   end DMA_Out_Handler;

   ----------------
   -- Initialize --
   ----------------

   function Initialize (Callback : Audio_Callback) return Boolean is
      use RP.DMA;
      use RP.PIO;
      use RP.GPIO;
      use Noise_Nugget_SDK.Audio.PIO_I2S_ASM;

      Config : PIO_SM_Config := Default_SM_Config;

      Sample_Rate       : constant RP.Hertz := RP.Hertz (Sample_Frequency);
      Sample_Bits       : constant := 16;
      Cycles_Per_Sample : constant := 4;
      Channels          : constant := 2;

      DMA_Config : DMA_Configuration;
   begin
      -- GPIO --
      Data_Out.Configure (Output, Pull_Both, I2S_PIO.GPIO_Function);
      Data_In.Configure (Input, Pull_Both, I2S_PIO.GPIO_Function);
      BCLK.Configure (Output, Pull_Both, I2S_PIO.GPIO_Function);
      LRCLK.Configure (Output, Pull_Both, I2S_PIO.GPIO_Function);

      --  Square wave with PWM for the MCLK signal
      MCLK.Configure (RP.GPIO.Output, RP.GPIO.Floating, RP.GPIO.PWM);
      RP.PWM.Set_Frequency (MCLK_PWM,
                            Frequency => MCLK_Requested_Frequency * 2);
      RP.PWM.Set_Interval (MCLK_PWM, Clocks => 1);
      RP.PWM.Set_Duty_Cycle (MCLK_PWM, 1, 1);
      RP.PWM.Enable (MCLK_PWM);

      -- I2S PIO --

      Enable (I2S_PIO);
      Load (I2S_PIO,
            Prog   => Audio_I2s_Program_Instructions,
            Offset => I2S_Offset);

      Set_Out_Pins (Config, Data_Out.Pin, 1);
      Set_In_Pins (Config, Data_In.Pin);
      Set_Sideset_Pins (Config, LRCLK.Pin);
      Set_Sideset (Config, 2, False, False);
      Set_Out_Shift (Config, False, True, 32);
      Set_In_Shift (Config, False, True, 32);

      Set_Wrap (Config,
          Wrap        => I2S_Offset + Audio_I2s_Wrap,
          Wrap_Target => I2S_Offset + Audio_I2s_Wrap_Target);

      Set_Config (I2S_PIO, I2S_SM, Config);
      SM_Initialize (I2S_PIO, I2S_SM, I2S_Offset, Config);

      Set_Pin_Direction (I2S_PIO, I2S_SM, Data_Out.Pin, Output);
      Set_Pin_Direction (I2S_PIO, I2S_SM, Data_In.Pin, Input);
      Set_Pin_Direction (I2S_PIO, I2S_SM, BCLK.Pin, Output);
      Set_Pin_Direction (I2S_PIO, I2S_SM, LRCLK.Pin, Output);

      Execute (I2S_PIO, I2S_SM,
               PIO_Instruction (I2S_Offset + Offset_entry_point));

      Set_Clock_Frequency
        (Config,
         Sample_Rate * Sample_Bits * Channels * Cycles_Per_Sample);
      Set_Config (I2S_PIO, I2S_SM, Config);

      Set_Enabled (I2S_PIO, I2S_SM, True);

      RP_Interrupts.Attach_Handler (DMA_Out_Handler'Access,
                                    RP2040_SVD.Interrupts.DMA_IRQ_0_Interrupt,
                                    RP_Interrupts.Interrupt_Priority'Last);

      -- I2S DMA --
      DMA_Config.Trigger := I2S_OUT_DMA_Trigger;
      DMA_Config.High_Priority := True;
      DMA_Config.Increment_Read := True;
      DMA_Config.Increment_Write := False;
      DMA_Config.Data_Size := Transfer_32;
      DMA_Config.Quiet := False; -- Enable interrupt
      RP.DMA.Configure (I2S_OUT_DMA, DMA_Config);
      RP.DMA.Enable_IRQ (I2S_OUT_DMA, DMA_IRQ);

      DMA_Config.Trigger := I2S_IN_DMA_Trigger;
      DMA_Config.High_Priority := True;
      DMA_Config.Increment_Read := False;
      DMA_Config.Increment_Write := True;
      DMA_Config.Data_Size := Transfer_32;
      RP.DMA.Configure (I2S_IN_DMA, DMA_Config);

      --  Start a first transfer
      DMA_Out_Handler;

      G_Callback := Callback;

      return True;
   end Initialize;

   ---------------
   -- Init_Sine --
   ---------------

   procedure Init_Sine is
      --  Wrap fsin to convert to and from C_float
      function Sin (F : Float) return Float is
        (RP.ROM.Floating_Point.fsin (F));

      Pi        : constant := 3.14159;  --  probably enough digits
      W         : constant := 2.0 * Pi; --  angular velocity
      Gain      : Float;
      Period    : Float;                --  time per sample (seconds)
      F         : Float;
   begin
      Gain := Float (Interfaces.Integer_16'Last) * 0.8;
      Period := 1.0 / Float (Sine_Buffer'Length);
      for T in Sine_Buffer'Range loop
         --  F := Sin (2.0 * Pi * T * (1.0 / Sample_Rate));
         F := Float (T);
         F := F * Period;
         F := F * W;
         F := Sin (F);
         F := F * Gain;
         Sine_Buffer (T) := (Interfaces.Integer_16 (F),
                             Interfaces.Integer_16 (F));
      end loop;
   end Init_Sine;

begin
   Init_Sine;
end Noise_Nugget_SDK.Audio.I2S;
