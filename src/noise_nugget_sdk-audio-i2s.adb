with HAL; use HAL;
with RP.GPIO;
with RP.DMA;
with RP.PWM;
with RP_Interrupts;
with RP2040_SVD.Interrupts;
with Noise_Nugget_SDK.Audio.PIO_I2S_ASM;
with Cortex_M.NVIC;

package body Noise_Nugget_SDK.Audio.I2S is

   Data_In     : RP.GPIO.GPIO_Point := (Pin => 0);
   Data_Out    : RP.GPIO.GPIO_Point := (Pin => 1);
   LRCLK       : RP.GPIO.GPIO_Point := (Pin => 2);
   BCLK        : RP.GPIO.GPIO_Point := (Pin => 3);
   MCLK        : RP.GPIO.GPIO_Point := (Pin => 4);

   MCLK_PWM : constant RP.PWM.PWM_Slice := RP.PWM.To_PWM (MCLK).Slice;

   Zeroes : constant array (1 .. 64) of UInt32 := (others => 0);
   Dev_Null : array (1 .. 64) of UInt32 := (others => 0);

   G_Output_Callback : Audio_Callback := null
     with Atomic, Volatile;
   G_Input_Callback : Audio_Callback := null
     with Atomic, Volatile;

   ---------------------
   -- DMA_Out_Handler --
   ---------------------

   procedure DMA_Out_Handler is
      Buffer : System.Address;
      Len : UInt32;
   begin

      RP.DMA.Ack_IRQ (I2S_OUT_DMA, I2S_OUT_DMA_IRQ);

      if G_Output_Callback /= null then
         G_Output_Callback.all (Buffer, Len);
      else
         Buffer := Zeroes'Address;
         Len := Zeroes'Length;
      end if;

      RP.DMA.Start
        (Channel => I2S_OUT_DMA,
         From    => Buffer,
         To      => RP.PIO.TX_FIFO_Address (I2S_PIO, I2S_SM),
         Count   => Len);
   end DMA_Out_Handler;

   --------------------
   -- DMA_In_Handler --
   --------------------

   procedure DMA_In_Handler is
      Buffer : System.Address;
      Len : UInt32;
   begin

      RP.DMA.Ack_IRQ (I2S_IN_DMA, I2S_IN_DMA_IRQ);

      if G_Input_Callback /= null then
         G_Input_Callback.all (Buffer, Len);
      else
         Buffer := Dev_Null'Address;
         Len := Dev_Null'Length;
      end if;

      RP.DMA.Start
        (Channel => I2S_IN_DMA,
         From    => RP.PIO.RX_FIFO_Address (I2S_PIO, I2S_SM),
         To      => Buffer,
         Count   => Len);
   end DMA_In_Handler;

   ----------------
   -- Initialize --
   ----------------

   function Initialize (Sample_Rate     : Positive;
                        Output_Callback : Audio_Callback;
                        Input_Callback  : Audio_Callback)
                        return Boolean
   is
      use RP.PIO;
      use RP.GPIO;
      use Noise_Nugget_SDK.Audio.PIO_I2S_ASM;

      Config : PIO_SM_Config := Default_SM_Config;

      Sample_Frequency : constant RP.Hertz := RP.Hertz (Sample_Rate);
      MCLK_Requested_Frequency : constant RP.Hertz := 256 * Sample_Frequency;

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

      Load (I2S_PIO,
            Prog   => Audio_I2s_Program_Instructions,
            Offset => I2S_Offset);

      Set_Out_Pins (Config, Data_Out.Pin, 1);
      Set_In_Pins (Config, Data_In.Pin);
      Set_Sideset_Pins (Config, LRCLK.Pin);
      Set_Sideset (Config, 2, False, False);
      Set_Out_Shift (Config,
                     Shift_Right    => False,
                     Autopull       => True,
                     Pull_Threshold => Sample_Bits * Channels);
      Set_In_Shift (Config,
                    Shift_Right    => False,
                    Autopush       => True,
                    Push_Threshold => Sample_Bits * Channels);

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

      -- I2S DMA Output --
      RP_Interrupts.Attach_Handler (DMA_Out_Handler'Access,
                                    RP2040_SVD.Interrupts.DMA_IRQ_0_Interrupt,
                                    RP_Interrupts.Interrupt_Priority'Last);

      Cortex_M.NVIC.Set_Priority (RP2040_SVD.Interrupts.DMA_IRQ_0_Interrupt,
                                  Cortex_M.NVIC.Interrupt_Priority'First);

      DMA_Config.Trigger := I2S_OUT_DMA_Trigger;
      DMA_Config.High_Priority := True;
      DMA_Config.Increment_Read := True;
      DMA_Config.Increment_Write := False;
      DMA_Config.Data_Size := Transfer_32;
      DMA_Config.Quiet := False; -- Enable interrupt
      RP.DMA.Configure (I2S_OUT_DMA, DMA_Config);

      G_Output_Callback := Output_Callback;

      --  Start a first output transfer
      DMA_Out_Handler;
      RP.DMA.Enable_IRQ (I2S_OUT_DMA, I2S_OUT_DMA_IRQ);

      -- I2S DMA Input --
      RP_Interrupts.Attach_Handler (DMA_In_Handler'Access,
                                    RP2040_SVD.Interrupts.DMA_IRQ_1_Interrupt,
                                    RP_Interrupts.Interrupt_Priority'Last);

      Cortex_M.NVIC.Set_Priority (RP2040_SVD.Interrupts.DMA_IRQ_1_Interrupt,
                                  Cortex_M.NVIC.Interrupt_Priority'First);


      DMA_Config.Trigger := I2S_IN_DMA_Trigger;
      DMA_Config.High_Priority := False;
      DMA_Config.Increment_Read := False;
      DMA_Config.Increment_Write := True;
      DMA_Config.Data_Size := Transfer_32;
      DMA_Config.Quiet := False; -- Enable interrupt
      RP.DMA.Configure (I2S_IN_DMA, DMA_Config);

      G_Input_Callback := Input_Callback;

      --  Start a first input transfer
      DMA_In_Handler;
      RP.DMA.Enable_IRQ (I2S_IN_DMA, I2S_IN_DMA_IRQ);

      return True;
   end Initialize;

end Noise_Nugget_SDK.Audio.I2S;
