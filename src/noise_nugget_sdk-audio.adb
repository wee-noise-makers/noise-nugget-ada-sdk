with Noise_Nugget_SDK.Audio.AIC3105;
with Noise_Nugget_SDK.Audio.I2S;

package body Noise_Nugget_SDK.Audio is

   -----------
   -- Start --
   -----------

   function Start (Sample_Rate     : Positive;
                   Output_Callback : Audio_Callback;
                   Input_Callback  : Audio_Callback)
                   return Boolean
   is
   begin
      if not I2S.Initialize (Sample_Rate, Output_Callback, Input_Callback)
      then
         return False;
      end if;

      return AIC3105.Initialize;
   end Start;

   procedure Set_HP_Volume (L, R : Audio_Volume)
                            renames AIC3105.Set_HP_Volume;
   procedure Enable_Speaker (L, R : Boolean; Gain : HAL.UInt2 := 0)
                             renames AIC3105.Enable_Speaker;
   procedure Set_Speaker_Volume (L, R : Audio_Volume)
                                 renames AIC3105.Set_Speaker_Volume;
   procedure Set_Line_Out_Volume (L, R : Audio_Volume)
                                 renames AIC3105.Set_Line_Out_Volume;

   procedure Set_Line_Volume (Line : Line_In_Id; L, R : Audio_Volume)
                              renames AIC3105.Set_Line_Volume;

   procedure Set_ADC_Volume (L, R : Audio_Volume)
                             renames AIC3105.Set_ADC_Volume;

   procedure Enable_Mic_Bias renames AIC3105.Enable_Mic_Bias;

end Noise_Nugget_SDK.Audio;
