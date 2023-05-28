with Interfaces;

package Noise_Nugget_SDK.Audio is

   type Stereo_Point is record
      L, R : Interfaces.Integer_16;
   end record
     with Size => 32;

   type Stereo_Buffer is array (0 .. 63) of Stereo_Point;

   type Audio_Callback is access procedure (Output : out Stereo_Buffer);

   function Start (Callback : Audio_Callback) return Boolean;

   type Audio_Volume is new Float range 0.0 .. 1.0;

   procedure Set_HP_Volume (L, R : Audio_Volume);

end Noise_Nugget_SDK.Audio;
