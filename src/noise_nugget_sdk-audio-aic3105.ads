private package Noise_Nugget_SDK.Audio.AIC3105 is

   type DAC_Sample_Rate is (SR_8000, SR_16000, SR_22050,
                            SR_32000, SR_44100, SR_48000);

   function Initialize (SR : DAC_Sample_Rate) return Boolean;

   procedure Set_HP_Volume (L, R : Audio_Volume);

   procedure Enable_Line_Out (L, R : Boolean);
   procedure Set_Line_Out_Volume (L2L, R2R : Audio_Volume;
                                  L2R, R2L : Audio_Volume := 0.0);

   procedure Enable_Speaker (L, R : Boolean; Gain : HAL.UInt2 := 0);
   procedure Set_Speaker_Volume (L2L, R2R : Audio_Volume;
                                 L2R, R2L : Audio_Volume := 0.0)
                                 renames Set_Line_Out_Volume;

   procedure Set_Line_Boost (Line : Line_In_Id;
                             L2L, L2R, R2L, R2R : Line_Boost := Disconect);

   procedure Set_ADC_Volume (L, R : Audio_Volume);

   procedure Enable_Mic_Bias;

private

   type Out_Mixer_Source
   is (LINE2_L, PGA_L, DAC_L1, LINE2_R, PGA_R, DAC_R1);

   type Out_Mixer_Sink
   is (HP_L_OUT, HP_L_COM, HP_R_OUT, HP_R_COM, LINE_OUT_L, LINE_OUT_R);

   Source_Register_Offset : constant array (Out_Mixer_Source)
     of HAL.UInt8
       := (LINE2_L => 0,
           PGA_L   => 1,
           DAC_L1  => 2,
           LINE2_R => 3,
           PGA_R   => 4,
           DAC_R1  => 5);

   Sink_Base_Register : constant array (Out_Mixer_Sink) of HAL.UInt8
     := (HP_L_OUT   => 45,
         HP_L_COM   => 52,
         HP_R_OUT   => 59,
         HP_R_COM   => 66,
         LINE_OUT_L => 80,
         LINE_OUT_R => 87);

   procedure Power_On (Sink : Out_Mixer_Sink);
   procedure Power_Off (Sink : Out_Mixer_Sink);
   procedure Mute (Sink : Out_Mixer_Sink);
   procedure Unmute (Sink : Out_Mixer_Sink);
   procedure Route (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink);
   procedure Unroute (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink);
   procedure Set_Volume (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink;
                         Vol : HAL.UInt7);
   procedure Set_Volume (Source : Out_Mixer_Source; Sink : Out_Mixer_Sink;
                         Vol : Audio_Volume);

   --  Page select register
   AIC3X_PAGE_SELECT : constant := 0;
   --  Software reset register
   AIC3X_RESET : constant := 1;
   --  Codec Sample rate select register
   AIC3X_SAMPLE_RATE_SEL_REG : constant := 2;
   --  PLL progrramming register A
   AIC3X_PLL_PROGA_REG : constant := 3;
   --  PLL progrramming register B
   AIC3X_PLL_PROGB_REG : constant := 4;
   --  PLL progrramming register C
   AIC3X_PLL_PROGC_REG : constant := 5;
   --  PLL progrramming register D
   AIC3X_PLL_PROGD_REG : constant := 6;
   --  Codec datapath setup register
   AIC3X_CODEC_DATAPATH_REG : constant := 7;
   --  Audio serial data interface control register A
   AIC3X_ASD_INTF_CTRLA : constant := 8;
   --  Audio serial data interface control register B
   AIC3X_ASD_INTF_CTRLB : constant := 9;
   --  Audio serial data interface control register C
   AIC3X_ASD_INTF_CTRLC : constant := 10;
   --  Audio overflow status and PLL R value programming register
   AIC3X_OVRF_STATUS_AND_PLLR_REG : constant := 11;
   --  Audio codec digital filter control register
   AIC3X_CODEC_DFILT_CTRL : constant := 12;
   --  Headset/button press detection register
   AIC3X_HEADSET_DETECT_CTRL_A : constant := 13;
   AIC3X_HEADSET_DETECT_CTRL_B : constant := 14;
   --  ADC PGA Gain control registers
   LADC_VOL : constant := 15;
   RADC_VOL : constant := 16;
   --  MIC3 control registers
   MIC3LR_2_LADC_CTRL : constant := 17;
   MIC3LR_2_RADC_CTRL : constant := 18;
   --  Line1 Input control registers
   LINE1L_2_LADC_CTRL : constant := 19;
   LINE1R_2_LADC_CTRL : constant := 21;
   LINE1R_2_RADC_CTRL : constant := 22;
   LINE1L_2_RADC_CTRL : constant := 24;
   --  Line2 Input control registers
   LINE2L_2_LADC_CTRL : constant := 20;
   LINE2R_2_RADC_CTRL : constant := 23;
   --  MICBIAS Control Register
   MICBIAS_CTRL : constant := 25;

   --  AGC Control Registers A, B, C
   LAGC_CTRL_A : constant := 26;
   LAGC_CTRL_B : constant := 27;
   LAGC_CTRL_C : constant := 28;
   RAGC_CTRL_A : constant := 29;
   RAGC_CTRL_B : constant := 30;
   RAGC_CTRL_C : constant := 31;

   --  DAC Power and Left High Power Output control registers
   DAC_PWR : constant := 37;
   HPLCOM_CFG : constant := 37;
   --  Right High Power Output control registers
   HPRCOM_CFG : constant := 38;
   --  High Power Output Stage Control Register
   HPOUT_SC : constant := 40;
   --  DAC Output Switching control registers
   DAC_LINE_MUX : constant := 41;
   --  High Power Output Driver Pop Reduction registers
   HPOUT_POP_REDUCTION : constant := 42;
   --  DAC Digital control registers
   LDAC_VOL : constant := 43;
   RDAC_VOL : constant := 44;
   --  Left High Power Output control registers
   LINE2L_2_HPLOUT_VOL : constant := 45;
   PGAL_2_HPLOUT_VOL : constant := 46;
   DACL1_2_HPLOUT_VOL : constant := 47;
   LINE2R_2_HPLOUT_VOL : constant := 48;
   PGAR_2_HPLOUT_VOL : constant := 49;
   DACR1_2_HPLOUT_VOL : constant := 50;
   HPLOUT_CTRL : constant := 51;
   --  Left High Power COM control registers
   LINE2L_2_HPLCOM_VOL : constant := 52;
   PGAL_2_HPLCOM_VOL : constant := 53;
   DACL1_2_HPLCOM_VOL : constant := 54;
   LINE2R_2_HPLCOM_VOL : constant := 55;
   PGAR_2_HPLCOM_VOL : constant := 56;
   DACR1_2_HPLCOM_VOL : constant := 57;
   HPLCOM_CTRL : constant := 58;
   --  Right High Power Output control registers
   LINE2L_2_HPROUT_VOL : constant := 59;
   PGAL_2_HPROUT_VOL : constant := 60;
   DACL1_2_HPROUT_VOL : constant := 61;
   LINE2R_2_HPROUT_VOL : constant := 62;
   PGAR_2_HPROUT_VOL : constant := 63;
   DACR1_2_HPROUT_VOL : constant := 64;
   HPROUT_CTRL : constant := 65;
   --  Right High Power COM control registers
   LINE2L_2_HPRCOM_VOL : constant := 66;
   PGAL_2_HPRCOM_VOL : constant := 67;
   DACL1_2_HPRCOM_VOL : constant := 68;
   LINE2R_2_HPRCOM_VOL : constant := 69;
   PGAR_2_HPRCOM_VOL : constant := 70;
   DACR1_2_HPRCOM_VOL : constant := 71;
   HPRCOM_CTRL : constant := 72;
   --  Mono Line Output Plus/Minus control registers
   LINE2L_2_MONOLOPM_VOL : constant := 73;
   PGAL_2_MONOLOPM_VOL : constant := 74;
   DACL1_2_MONOLOPM_VOL : constant := 75;
   LINE2R_2_MONOLOPM_VOL : constant := 76;
   PGAR_2_MONOLOPM_VOL : constant := 77;
   DACR1_2_MONOLOPM_VOL : constant := 78;
   MONOLOPM_CTRL : constant := 79;
   --  Left Line Output Plus/Minus control registers
   LINE2L_2_LLOPM_VOL : constant := 80;
   PGAL_2_LLOPM_VOL : constant := 81;
   DACL1_2_LLOPM_VOL : constant := 82;
   LINE2R_2_LLOPM_VOL : constant := 83;
   PGAR_2_LLOPM_VOL : constant := 84;
   DACR1_2_LLOPM_VOL : constant := 85;
   LLOPM_CTRL : constant := 86;
   --  Right Line Output Plus/Minus control registers
   LINE2L_2_RLOPM_VOL : constant := 87;
   PGAL_2_RLOPM_VOL : constant := 88;
   DACL1_2_RLOPM_VOL : constant := 89;
   LINE2R_2_RLOPM_VOL : constant := 90;
   PGAR_2_RLOPM_VOL : constant := 91;
   DACR1_2_RLOPM_VOL : constant := 92;
   RLOPM_CTRL : constant := 93;

   MODULE_POWER_STATUS : constant := 94;

   --  GPIO/IRQ registers
   AIC3X_STICKY_IRQ_FLAGS_REG : constant := 96;
   AIC3X_RT_IRQ_FLAGS_REG : constant := 97;

   AIC3X_CLOCK_REG : constant := 101;
   --  Clock generation control register
   AIC3X_CLKGEN_CTRL_REG : constant := 102;
   --  New AGC registers
   LAGCN_ATTACK : constant := 103;
   LAGCN_DECAY : constant := 104;
   RAGCN_ATTACK : constant := 105;
   RAGCN_DECAY : constant := 106;
   --  New Programmable ADC Digital Path and I2C Bus Condition Register
   NEW_ADC_DIGITALPATH : constant := 107;
   --  Passive Analog Signal Bypass Selection During Powerdown Register
   PASSIVE_BYPASS : constant := 108;
   --  DAC Quiescent Current Adjustment Register
   DAC_ICC_ADJ : constant := 109;

end Noise_Nugget_SDK.Audio.AIC3105;
