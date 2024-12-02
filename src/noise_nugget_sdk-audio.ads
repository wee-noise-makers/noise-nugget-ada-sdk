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
   procedure Set_Speaker_Volume (L2L, R2R : Audio_Volume;
                                 L2R, R2L : Audio_Volume := 0.0);
   procedure Set_Line_Out_Volume (L2L, R2R : Audio_Volume;
                                  L2R, R2L : Audio_Volume := 0.0);

   type Line_In_Id is range 1 .. 3;
   type Line_Boost is new Integer range 0 .. 9;
   Disconect : constant Line_Boost := 0;

   procedure Set_Line_Boost (Line : Line_In_Id;
                             L2L, L2R, R2L, R2R : Line_Boost := Disconect);

   procedure Set_ADC_Volume (L, R : Audio_Volume);
   --  Set Analog to Digital Converter volume

   procedure Enable_Mic_Bias;

   function Jack_Detect return Boolean;

end Noise_Nugget_SDK.Audio;
