with HAL; use HAL;
with HAL.I2C;
with RP.GPIO; use RP.GPIO;

with Noise_Nugget_SDK.I2C;
with Noise_Nugget_SDK.Audio.IO_Expander;

package body Noise_Nugget_SDK.Audio.AIC3105 is

   AIC3105_Addr : constant := 16#18#;

   --  We keep a local copy of the registers that we update when writing to
   --  the device.
   Register_Local_Copy : array (HAL.UInt8 range 0 .. 109) of HAL.UInt8 :=
     (2#0000000_0#, -- 0
      2#0_0000000#, -- 1
      2#0000_0000#, -- 2
      2#0_0010_000#, -- 3
      2#0000001_0#, -- 4
      2#00000000#, -- 5
      2#000000_00#, -- 6
      2#0000_0000#, -- 7
      2#0000_0000#, -- 8
      2#0000_0000#, -- 9
      2#0000_0000#, -- 10
      2#0000_0001#, -- 11
      2#0000_0000#, -- 12
      2#0000_0000#, -- 13
      2#0000_0000#, -- 14
      2#1_0000000#, -- 15
      2#1_0000000#, -- 16
      2#1111_1111#, -- 17
      2#1111_1111#, -- 18
      2#0_1111_0_00#, -- 19
      2#0_1111_0_00#, -- 20
      2#0_1111_000#, -- 21
      2#0_1111_0_00#, -- 22
      2#0_1111_0_00#, -- 23
      2#0_1111_000#, -- 24
      2#0000_0000#, -- 25
      2#0000_0000#, -- 26
      2#1111111_0#, -- 27
      2#0000_0000#, -- 28
      2#0000_0000#, -- 29
      2#1111111_0#, -- 30
      2#0000_0000#, -- 31
      2#0000_0000#, -- 32
      2#0000_0000#, -- 33
      2#0000_0000#, -- 34
      2#0000_0000#, -- 35
      2#0000_0000#, -- 36
      2#0000_0000#, -- 37
      2#0000_0000#, -- 38
      2#0000_0000#, -- 39
      2#0000_0000#, -- 40
      2#0000_0000#, -- 41
      2#0000_0000#, -- 42
      2#1_0000000#, -- 43
      2#1_0000000#, -- 44
      2#0000_0000#, -- 45
      2#0000_0000#, -- 46
      2#0000_0000#, -- 47
      2#0000_0000#, -- 48
      2#0000_0000#, -- 49
      2#0000_0000#, -- 50
      2#0000_0_1_1_0#, -- 51
      2#0000_0000#, -- 52
      2#0000_0000#, -- 53
      2#0000_0000#, -- 54
      2#0000_0000#, -- 55
      2#0000_0000#, -- 56
      2#0000_0000#, -- 57
      2#0000_0_1_1_0#, -- 58
      2#0000_0000#, -- 59
      2#0000_0000#, -- 60
      2#0000_0000#, -- 61
      2#0000_0000#, -- 62
      2#0000_0000#, -- 63
      2#0000_0000#, -- 64
      2#0000_0_0_1_0#, -- 65
      2#0000_0000#, -- 66
      2#0000_0000#, -- 67
      2#0000_0000#, -- 68
      2#0000_0000#, -- 69
      2#0000_0000#, -- 70
      2#0000_0000#, -- 71
      2#0000_0_0_1_0#, -- 72
      2#0000_0000#, -- 73
      2#0000_0000#, -- 74
      2#0000_0000#, -- 75
      2#0000_0000#, -- 76
      2#0000_0000#, -- 77
      2#0000_0000#, -- 78
      2#0000_0000#, -- 79
      2#0000_0000#, -- 80
      2#0000_0000#, -- 81
      2#0000_0000#, -- 82
      2#0000_0000#, -- 83
      2#0000_0000#, -- 84
      2#0000_0000#, -- 85
      2#0000_0_0_1_0#, -- 86
      2#0000_0000#, -- 87
      2#0000_0000#, -- 88
      2#0000_0000#, -- 89
      2#0000_0000#, -- 90
      2#0000_0000#, -- 91
      2#0000_0000#, -- 92
      2#0000_0_0_1_0#, -- 93
      2#0000_0000#, -- 94
      2#0000_0000#, -- 95
      2#0000_0000#, -- 96
      2#0000_0000#, -- 97
      2#0000_0000#, -- 98
      2#0000_0000#, -- 99
      2#0000_0000#, -- 100
      2#0000_0000#, -- 101
      2#0000_0010#, -- 102
      2#0000_0000#, -- 103
      2#0000_0000#, -- 104
      2#0000_0000#, -- 105
      2#0000_0000#, -- 106
      2#0000_0000#, -- 107
      2#0000_0000#, -- 108
      2#0000_0000#); -- 109

   generic
      type Output_Type is mod <>;
      Min        : Output_Type;
      Max        : Output_Type;
      Mute_Value : Output_Type;
   function Gen_Volume_To_UInt (V : Audio_Volume) return Output_Type;

   --------------------
   -- Write_Register --
   --------------------

   function Write_Register (Reg, Val : HAL.UInt8)
                            return Boolean
   is

      use Noise_Nugget_SDK.I2C;
      use HAL.I2C;

      Status : HAL.I2C.I2C_Status;
   begin
      Mem_Write
        (Addr => AIC3105_Addr * 2,
         Mem_Addr => HAL.UInt16 (Reg),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data =>  (1 => Val),
         Status => Status);

      if Status = HAL.I2C.Ok then
         Register_Local_Copy (Reg) := Val;
         return True;
      else
         return False;
      end if;
   end Write_Register;

   ------------------------
   -- Write_Register_Bit --
   ------------------------

   function Write_Register_Bit (Reg : HAL.UInt8;
                                Pos : HAL.UInt3;
                                Value : HAL.Bit)
                                return Boolean
   is
      Current : UInt8 := Register_Local_Copy (Reg);

      Mask : constant UInt8 := UInt8 (1) * 2**Natural (Pos);
   begin
      if Value = 1 then
         Current := Current or Mask;
      else
         Current := Current and (not Mask);
      end if;

      return Write_Register (Reg, Current);
   end Write_Register_Bit;

   --------------------------
   -- Write_Register_Multi --
   --------------------------

   function Write_Register_Multi (Reg      : HAL.UInt8;
                                  Msb, Lsb : HAL.UInt3;
                                  Value    : HAL.UInt8)
                                  return Boolean
   is
      Current : UInt8 := Register_Local_Copy (Reg);

      Mask : UInt8 := 1 * 2**Natural (Lsb);
   begin
      --  Clear bits for the range we case about
      for X in Lsb .. Msb loop
         Current := Current and not Mask;
         Mask := Mask * 2;
      end loop;

      Current := Current or Value * 2**Natural (Lsb);
      return Write_Register (Reg, Current);
   end Write_Register_Multi;

   -------------------
   -- Read_Register --
   -------------------

   function Read_Register (Reg : HAL.UInt8) return HAL.UInt8 is

      use Noise_Nugget_SDK.I2C;
      use HAL.I2C;

      Status : HAL.I2C.I2C_Status;
      Data : HAL.I2C.I2C_Data (1 .. 1);
   begin
      Mem_Read (AIC3105_Addr * 2,
                UInt16 (Reg),
                HAL.I2C.Memory_Size_8b,
                Data,
                Status);

      if Status = Ok then
         return Data (Data'First);
      else
         return 0;
      end if;
   end Read_Register;

   ------------------------
   -- Gen_Volume_To_UInt --
   ------------------------

   function Gen_Volume_To_UInt (V : Audio_Volume) return Output_Type is
   begin
      if V = 0.0 then
         return Mute_Value;
      else
         if Max > Min then
            declare
               Amplitude : constant Output_Type := Max - Min;

               Val : constant Output_Type :=
                 Output_Type (Float (V) * Float (Amplitude));
            begin
               return Min + Val;
            end;
         else
            declare
               Amplitude : constant Output_Type := Min - Max;

               Val : constant Output_Type :=
                 Output_Type ((1.0 - Float (V)) * Float (Amplitude));
            begin
               return Max + Val;
            end;
         end if;
      end if;
   end Gen_Volume_To_UInt;

   -------------------------
   -- Output_Stage_Volume --
   -------------------------

   function Output_Stage_Volume
   is new Gen_Volume_To_UInt (HAL.UInt7,
                              Min => 117,
                              Max => 0,
                              Mute_Value => 118);
   ----------------
   -- Initialize --
   ----------------

   function Initialize return Boolean is
      Success : Boolean;
   begin

      Noise_Nugget_SDK.Audio.IO_Expander.Enable_Codec;

      --  Select Page 0
      Success := Write_Register_Bit (AIC3X_PAGE_SELECT, 0, 0);

      --  Soft reset
      Success := Success and then
        Write_Register_Bit (AIC3X_RESET, 7, 1);

      --  Let's start with clock configuration.
      --
      --  fS(ref) = (PLLCLK_IN × J.D × R)/(2048 × P)
      --
      --  Using a 24MHz MCLK:
      --  fS(ref) = (PLLCLK_IN × J.D × R)/(2048 × P)
      --  fS(ref) = (24_000_000 × 7.5264 × 1)/(2048 × 2) = 44_100.00Hz
      --
      --  PLLCLK_IN can be either MCLK or BCLK. Using BCLK (bit clock) we can
      --  avoid using an extra GPIO from the MCU or an extra external clock.
      --
      --  Using BCLK with 2 words (stereo) of 16bit audio data:
      --  BCLK = 2 * 16 * 44100 = 1_411_200Hz
      --  fS(ref) = (PLLCLK_IN × J.D × R)/(2048 × P)
      --  fS(ref) = (1_411_200 × 32.0 × 2)/(2048 × 1) = 44_100.00Hz
      --
      --  That gives us:
      --  J = 32
      --  D = 0
      --  R = 2
      --  P = 1
      --
      --  However, the AIC3105 documentation also states that PLLCLK_IN / P
      --  should be greater than 2MHz. With this set up we have ~1.4MHz...
      --  Other AIC310X devices (e.g. 3104) which seem to use the same PLL
      --  only require 512KHz. Maybe it's mistake in the 3105 documentation,
      --  or the PLL is different from the other 310X.

      --  TODO: worth a try sometime. Until then, let's use MCLK...

      --  PLL P = 2
      Success := Success and then
        Write_Register_Multi (AIC3X_PLL_PROGA_REG, 2, 0, 2);

      --  PLL R = 1
      Success := Success and then
        Write_Register_Multi (AIC3X_OVRF_STATUS_AND_PLLR_REG, 3, 0, 1);

      --  PLL J = 7
      Success := Success and then
        Write_Register_Multi (AIC3X_PLL_PROGB_REG, 7, 2, 7);

      --  PLL D = 5264
      declare
         PLL_D : constant UInt16 := 5264;
         REG_C : constant UInt16 := Shift_Right (PLL_D, 6);
         REG_D : constant UInt16 := PLL_D and 16#3F#;
      begin
         Success := Success and then
           Write_Register_Multi (AIC3X_PLL_PROGC_REG, 7, 0, UInt8 (REG_C));
         Success := Success and then
           Write_Register_Multi (AIC3X_PLL_PROGD_REG, 7, 2, UInt8 (REG_D));
      end;

      --  Select the PLLCLK_IN source. 0: MCLK, 1: GPIO2, 2: BCLK
      Success := Success and then
        Write_Register_Multi (AIC3X_CLKGEN_CTRL_REG, 5, 4, 0);

      --  Select the CLKDIV_IN source. 0: MCLK, 1: GPIO2, 2: BCLK
      --
      --  Note: When PLL is used CLKDIV_IN still needs some kind of clock
      --  signal. So if there's no MCLK, BCLK should be used here as well
      Success := Success and then
        Write_Register_Multi (AIC3X_CLKGEN_CTRL_REG, 6, 7, 0);

      --  Enable PLL
      Success := Success and then
        Write_Register_Bit (AIC3X_PLL_PROGA_REG, 7, 1);

      --  Set FS(ref) value for AGC time constants to 44.1KHz
      Success := Success and then
        Write_Register_Bit (AIC3X_CODEC_DATAPATH_REG, 7, 1);

      --  CODEC_CLKIN Source Selection. 0: PLLDIV_OUT. 1: CLKDIV_OUT
      Success := Success and then
        Write_Register_Bit (AIC3X_CLOCK_REG, 0, 0);

      --  Note: We leave the ADC Sample Rate Select and DAC Sample Rate Select
      --  at the default value: fs(ref) / 1

      --  Audio Serial Data Interface at the default settings: I2S
      --  mode, 16bits words,
      Success := Success and then
        Write_Register_Multi (AIC3X_ASD_INTF_CTRLB, 7, 6, 2#00#);

      --  Power outputs
      Power_On (HP_L_OUT);
      Power_On (HP_R_OUT);

      --  L and R DACs Power On
      Success := Success and then
        Write_Register_Multi (DAC_PWR, 7, 6, 2#11#);

      --  Left DAC plays left input data
      Success := Success and then
        Write_Register_Multi (AIC3X_CODEC_DATAPATH_REG, 4, 3, 2#01#);
      --  Right DAC plays right input data
      Success := Success and then
        Write_Register_Multi (AIC3X_CODEC_DATAPATH_REG, 2, 1, 2#01#);

      --  Unmute L DAC
      Success := Success and then
        Write_Register_Bit (LDAC_VOL, 7, 0);
      --  Unmute R DAC
      Success := Success and then
        Write_Register_Bit (RDAC_VOL, 7, 0);

      --  Left-DAC output selects DAC_L1 path.
      Success := Success and then
        Write_Register_Multi (DAC_LINE_MUX, 7, 6, 0);
      --  Right-DAC output selects DAC_R1 path.
      Success := Success and then
        Write_Register_Multi (DAC_LINE_MUX, 5, 4, 0);

      --  DAC to HP
      Route (DAC_L1, HP_L_OUT);
      Route (DAC_R1, HP_R_OUT);

      --  DAC to Line-Out
      Route (DAC_L1, LINE_OUT_L);
      Route (DAC_R1, LINE_OUT_R);

      --  Enable Left ADC
      Success := Success and then
        Write_Register_Bit (LINE1L_2_LADC_CTRL, 2, 1);
      --  Enable Right ADC
      Success := Success and then
        Write_Register_Bit (LINE1R_2_RADC_CTRL, 2, 1);

      --  Unmute L ADC PGA
      Success := Success and then
        Write_Register_Bit (LADC_VOL, 7, 0);
      --  Unmute R ADC PGA
      Success := Success and then
        Write_Register_Bit (RADC_VOL, 7, 0);

      --  Programs high-power outputs for ac-coupled driver configuration
      Success := Success and then
        Write_Register_Bit (AIC3X_HEADSET_DETECT_CTRL_B, 7, 1);

      --  HPLCOM configured as independent single-ended output
      Success := Success and then
        Write_Register_Multi (HPLCOM_CFG, 5, 4, 2);

      --  HPRCOM configured as independent single-ended output
      Success := Success and then
        Write_Register_Multi (HPRCOM_CFG, 5, 3, 1);

      --  Unmute outputs
      Unmute (HP_L_OUT);
      Unmute (HP_R_OUT);

      return Success;
   end Initialize;

   --------------
   -- Power_On --
   --------------

   procedure Power_On (Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 := Sink_Base_Register (Sink) + 6;
   begin
      if not Write_Register_Bit (Reg, 0, 1) then
         raise Program_Error;
      end if;
   end Power_On;

   ---------------
   -- Power_Off --
   ---------------

   procedure Power_Off (Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 := Sink_Base_Register (Sink) + 6;
   begin
      if not Write_Register_Bit (Reg, 0, 0) then
         raise Program_Error;
      end if;
   end Power_Off;

   ----------
   -- Mute --
   ----------

   procedure Mute (Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 := Sink_Base_Register (Sink) + 6;
   begin
      if not Write_Register_Bit (Reg, 3, 0) then
         raise Program_Error;
      end if;
   end Mute;

   ------------
   -- Unmute --
   ------------

   procedure Unmute (Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 := Sink_Base_Register (Sink) + 6;
   begin
      if not Write_Register_Bit (Reg, 3, 1) then
         raise Program_Error;
      end if;
   end Unmute;

   -----------
   -- Route --
   -----------

   procedure Route (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 :=
        Sink_Base_Register (Sink) + Source_Register_Offset (Source);
   begin
      if not Write_Register_Bit (Reg, 7, 1) then
         raise Program_Error;
      end if;
   end Route;

   -------------
   -- Unroute --
   -------------

   procedure Unroute (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink) is
      Reg : constant HAL.UInt8 :=
        Sink_Base_Register (Sink) + Source_Register_Offset (Source);
   begin
      if not Write_Register_Bit (Reg, 7, 0) then
         raise Program_Error;
      end if;
   end Unroute;

   ----------------
   -- Set_Volume --
   ----------------

   procedure Set_Volume (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink;
                         Vol : HAL.UInt7)
   is
      Reg : constant HAL.UInt8 :=
        Sink_Base_Register (Sink) + Source_Register_Offset (Source);
   begin
      if not Write_Register_Multi (Reg, 6, 0, HAL.UInt8 (Vol)) then
         raise Program_Error;
      end if;
   end Set_Volume;

   ----------------
   -- Set_Volume --
   ----------------

   procedure Set_Volume (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink;
                         Vol : Audio_Volume)
   is
   begin
      Set_Volume (Source, Sink, Output_Stage_Volume (Vol));
   end Set_Volume;

   -------------------
   -- Set_HP_Volume --
   -------------------

   procedure Set_HP_Volume (L, R : Audio_Volume) is
   begin
      Set_Volume (DAC_L1, HP_L_OUT, L);
      Set_Volume (DAC_R1, HP_R_OUT, R);
   end Set_HP_Volume;

   ---------------------
   -- Enable_Line_Out --
   ---------------------

   procedure Enable_Line_Out (L, R : Boolean) is
   begin
      if L then
         Power_On (LINE_OUT_L);
         Route (DAC_L1, LINE_OUT_L);
         Route (DAC_L1, LINE_OUT_R);
         Unmute (LINE_OUT_L);
      else
         Power_Off (LINE_OUT_L);
         Unroute (DAC_L1, LINE_OUT_L);
         Unroute (DAC_L1, LINE_OUT_R);
         Mute (LINE_OUT_L);
      end if;

      if R then
         Power_On (LINE_OUT_R);
         Route (DAC_R1, LINE_OUT_R);
         Route (DAC_R1, LINE_OUT_L);
         Unmute (LINE_OUT_R);
      else
         Power_Off (LINE_OUT_R);
         Unroute (DAC_R1, LINE_OUT_R);
         Unroute (DAC_R1, LINE_OUT_L);
         Mute (LINE_OUT_R);
      end if;
   end Enable_Line_Out;

   -------------------------
   -- Set_Line_Out_Volume --
   -------------------------

   procedure Set_Line_Out_Volume (L2L, R2R : Audio_Volume;
                                  L2R, R2L : Audio_Volume := 0.0)
   is
   begin
      Set_Volume (DAC_L1, LINE_OUT_L, L2L);
      Set_Volume (DAC_L1, LINE_OUT_R, L2R);

      Set_Volume (DAC_R1, LINE_OUT_R, R2R);
      Set_Volume (DAC_R1, LINE_OUT_L, R2L);
   end Set_Line_Out_Volume;

   --------------------
   -- Enable_Speaker --
   --------------------

   procedure Enable_Speaker (L, R : Boolean; Gain : HAL.UInt2 := 0) is
      use Noise_Nugget_SDK.Audio.IO_Expander;
   begin
      case Gain is
         when 0 => Set_Speaker_Gain (False, False);
         when 1 => Set_Speaker_Gain (True, False);
         when 2 => Set_Speaker_Gain (False, True);
         when 3 => Set_Speaker_Gain (True, True);
      end case;

      Enable_Line_Out (L, R);
      IO_Expander.Enable_Speaker (L, R);

   end Enable_Speaker;

   --------------------
   -- Set_Line_Boost --
   --------------------

   procedure Set_Line_Boost (Line : Line_In_Id;
                             L2L, L2R, R2L, R2R : Line_Boost := Disconect)
   is
      function To_Reg_Val (B : Line_Boost) return UInt8 is
      begin
         if B = 0 then
            return 2#1111#; -- Mute/disconnect
         else
            return (2#1000# + 1) - UInt8 (B);
         end if;
      end To_Reg_Val;

      L2LB : constant HAL.UInt8 := To_Reg_Val (L2L);
      L2RB : constant HAL.UInt8 := To_Reg_Val (L2R);
      R2LB : constant HAL.UInt8 := To_Reg_Val (R2L);
      R2RB : constant HAL.UInt8 := To_Reg_Val (R2R);
   begin
      case Line is
         when 1 =>
            if not Write_Register_Multi (LINE1L_2_LADC_CTRL, 6, 3, L2LB) then
               raise Program_Error;
            end if;
            if not Write_Register_Multi (LINE1L_2_RADC_CTRL, 6, 3, L2RB) then
               raise Program_Error;
            end if;
            if not Write_Register_Multi (LINE1R_2_LADC_CTRL, 6, 3, R2LB) then
               raise Program_Error;
            end if;
            if not Write_Register_Multi (LINE1R_2_RADC_CTRL, 6, 3, R2RB) then
               raise Program_Error;
            end if;

         when 2 =>
            if not Write_Register_Multi (LINE2L_2_LADC_CTRL, 6, 3, L2LB) then
               raise Program_Error;
            end if;
            if not Write_Register_Multi (LINE2R_2_RADC_CTRL, 6, 3, R2LB) then
               raise Program_Error;
            end if;

         when 3 =>
            if not Write_Register (MIC3LR_2_LADC_CTRL,
                                   Shift_Left (L2LB, 4) + R2LB)
            then
               raise Program_Error;
            end if;
            if not Write_Register (MIC3LR_2_RADC_CTRL,
                                   Shift_Left (L2RB, 4) + R2RB)
            then
               raise Program_Error;
            end if;
      end case;
   end Set_Line_Boost;

   --------------------
   -- Set_ADC_Volume --
   --------------------

   procedure Set_ADC_Volume (L, R : Audio_Volume) is
      function PGA_Volume
      is new Gen_Volume_To_UInt (HAL.UInt7,
                                 Min => 0,
                                 Max => 2#111_1111#,
                                 Mute_Value => 0);
   begin
      if L = 0.0 then
         --  Mute Left ADC PGA
         if not Write_Register (LADC_VOL, 2#1_0000000#) then
            raise Program_Error;
         end if;
      else
         --  Set Left ADC PGA Gain
         if not Write_Register (LADC_VOL, HAL.UInt8 (PGA_Volume (L))) then
            raise Program_Error;
         end if;
      end if;

      if R = 0.0 then
         --  Mute Right ADC PGA
         if not Write_Register (RADC_VOL, 2#1_0000000#) then
            raise Program_Error;
         end if;
      else
         --  Set Right ADC PGA Gain
         if not Write_Register (RADC_VOL, HAL.UInt8 (PGA_Volume (R))) then
            raise Program_Error;
         end if;
      end if;
   end Set_ADC_Volume;

   ---------------------
   -- Enable_Mic_Bias --
   ---------------------

   procedure Enable_Mic_Bias is
   begin
      if not Write_Register_Multi (MICBIAS_CTRL, 7, 6, 2#10#) then
         raise Program_Error;
      end if;
   end Enable_Mic_Bias;

end Noise_Nugget_SDK.Audio.AIC3105;
