with System;
with HAL;

package Noise_Nugget_SDK.Audio is

   type Audio_Callback
   is access procedure (Buffer             : out System.Address;
                        Stereo_Point_Count : out HAL.UInt32);

   function Start (Sample_Rate     : Positive;
                   Output_Callback : Audio_Callback;
                   Input_Callback  : Audio_Callback)
                   return Boolean;

   type Audio_Volume is new Float range 0.0 .. 1.0;

   procedure Set_HP_Volume (L, R : Audio_Volume);

   procedure Enable_Speaker (L, R : Boolean; Gain : HAL.UInt2 := 0);
   procedure Set_Speaker_Volume (L, R : Audio_Volume);
   procedure Set_Line_Out_Volume (L, R : Audio_Volume);

   type Line_In_Id is range 1 .. 3;

   procedure Set_Line_Volume (Line : Line_In_Id; L, R : Audio_Volume);

   procedure Enable_Mic (L, R : Boolean);
   --  Enable input 1 as single-ended microphone input

   procedure Set_Mic_Boost (L, R : Audio_Volume);
   --  Set volume boost for the microphone input

   procedure Set_ADC_Volume (L, R : Audio_Volume);
   --  Set Analog to Digital Converter volume

   procedure Mixer_To_Output (L, R : Boolean);
   --  Enable intrnal bypass from inputs to output

end Noise_Nugget_SDK.Audio;
