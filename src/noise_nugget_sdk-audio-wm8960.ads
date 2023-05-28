private with HAL;

private package Noise_Nugget_SDK.Audio.WM8960 is

   function Initialize return Boolean;

   procedure Set_HP_Volume (L, R : Audio_Volume);

private

   REG_LEFT_INPUT_VOLUME    : constant HAL.UInt7 := 16#00#;
   REG_RIGHT_INPUT_VOLUME   : constant HAL.UInt7 := 16#01#;
   REG_LOUT1_VOLUME         : constant HAL.UInt7 := 16#02#;
   REG_ROUT1_VOLUME         : constant HAL.UInt7 := 16#03#;
   REG_CLOCKING_1           : constant HAL.UInt7 := 16#04#;
   REG_ADC_DAC_CTRL_1       : constant HAL.UInt7 := 16#05#;
   REG_ADC_DAC_CTRL_2       : constant HAL.UInt7 := 16#06#;
   REG_AUDIO_INTERFACE_1    : constant HAL.UInt7 := 16#07#;
   REG_CLOCKING_2           : constant HAL.UInt7 := 16#08#;
   REG_AUDIO_INTERFACE_2    : constant HAL.UInt7 := 16#09#;
   REG_LEFT_DAC_VOLUME      : constant HAL.UInt7 := 16#0A#;
   REG_RIGHT_DAC_VOLUME     : constant HAL.UInt7 := 16#0B#;
   REG_RESET                : constant HAL.UInt7 := 16#0F#;
   REG_3D_CONTROL           : constant HAL.UInt7 := 16#10#;
   REG_ALC1                 : constant HAL.UInt7 := 16#11#;
   REG_ALC2                 : constant HAL.UInt7 := 16#12#;
   REG_ALC3                 : constant HAL.UInt7 := 16#13#;
   REG_NOISE_GATE           : constant HAL.UInt7 := 16#14#;
   REG_LEFT_ADC_VOLUME      : constant HAL.UInt7 := 16#15#;
   REG_RIGHT_ADC_VOLUME     : constant HAL.UInt7 := 16#16#;
   REG_ADDITIONAL_CONTROL_1 : constant HAL.UInt7 := 16#17#;
   REG_ADDITIONAL_CONTROL_2 : constant HAL.UInt7 := 16#18#;
   REG_PWR_MGMT_1           : constant HAL.UInt7 := 16#19#;
   REG_PWR_MGMT_2           : constant HAL.UInt7 := 16#1A#;
   REG_ADDITIONAL_CONTROL_3 : constant HAL.UInt7 := 16#1B#;
   REG_ANTI_POP_1           : constant HAL.UInt7 := 16#1C#;
   REG_ANTI_POP_2           : constant HAL.UInt7 := 16#1D#;
   REG_ADCL_SIGNAL_PATH     : constant HAL.UInt7 := 16#20#;
   REG_ADCR_SIGNAL_PATH     : constant HAL.UInt7 := 16#21#;
   REG_LEFT_OUT_MIX_1       : constant HAL.UInt7 := 16#22#;
   REG_RIGHT_OUT_MIX_2      : constant HAL.UInt7 := 16#25#;
   REG_MONO_OUT_MIX_1       : constant HAL.UInt7 := 16#26#;
   REG_MONO_OUT_MIX_2       : constant HAL.UInt7 := 16#27#;
   REG_LOUT2_VOLUME         : constant HAL.UInt7 := 16#28#;
   REG_ROUT2_VOLUME         : constant HAL.UInt7 := 16#29#;
   REG_MONO_OUT_VOLUME      : constant HAL.UInt7 := 16#2A#;
   REG_INPUT_BOOST_MIXER_1  : constant HAL.UInt7 := 16#2B#;
   REG_INPUT_BOOST_MIXER_2  : constant HAL.UInt7 := 16#2C#;
   REG_BYPASS_1             : constant HAL.UInt7 := 16#2D#;
   REG_BYPASS_2             : constant HAL.UInt7 := 16#2E#;
   REG_PWR_MGMT_3           : constant HAL.UInt7 := 16#2F#;
   REG_ADDITIONAL_CONTROL_4 : constant HAL.UInt7 := 16#30#;
   REG_CLASS_D_CONTROL_1    : constant HAL.UInt7 := 16#31#;
   REG_CLASS_D_CONTROL_3    : constant HAL.UInt7 := 16#33#;
   REG_PLL_N                : constant HAL.UInt7 := 16#34#;
   REG_PLL_K_1              : constant HAL.UInt7 := 16#35#;
   REG_PLL_K_2              : constant HAL.UInt7 := 16#36#;
   REG_PLL_K_3              : constant HAL.UInt7 := 16#37#;

end Noise_Nugget_SDK.Audio.WM8960;
