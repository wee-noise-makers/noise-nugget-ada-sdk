private package Noise_Nugget_SDK.Audio.IO_Expander is

   procedure Enable_Codec;

   procedure Enable_Speaker (L, R : Boolean := True);

   procedure Set_Speaker_Gain (G0, G1 : Boolean);

   function Jack_Detect return Boolean;

end Noise_Nugget_SDK.Audio.IO_Expander;
