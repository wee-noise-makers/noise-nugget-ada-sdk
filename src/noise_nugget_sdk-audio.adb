with Noise_Nugget_SDK.Audio.WM8960;
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

      return WM8960.Initialize;
   end Start;

   procedure Set_HP_Volume (L, R : Audio_Volume)
                            renames WM8960.Set_HP_Volume;
   procedure Set_Line_Volume (Line : Line_In_Id; L, R : Audio_Volume)
                              renames WM8960.Set_Line_Volume;
   procedure Enable_Mic (L, R : Boolean)
                         renames WM8960.Enable_Mic;

   procedure Set_Mic_Boost (L, R : Audio_Volume)
                            renames WM8960.Set_Mic_Boost;
   procedure Set_ADC_Volume (L, R : Audio_Volume)
                            renames WM8960.Set_ADC_Volume;
   procedure Mixer_To_Output (L, R : Boolean)
                              renames WM8960.Mixer_To_Output;

end Noise_Nugget_SDK.Audio;
