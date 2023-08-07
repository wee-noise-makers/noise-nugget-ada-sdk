private package Noise_Nugget_SDK.Audio.I2S is

   function Initialize (Sample_Rate     : Positive;
                        Output_Callback : Audio_Callback;
                        Input_Callback  : Audio_Callback)
                        return Boolean;

end Noise_Nugget_SDK.Audio.I2S;
