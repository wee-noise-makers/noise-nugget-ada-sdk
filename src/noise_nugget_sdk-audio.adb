with Noise_Nugget_SDK.Audio.WM8960;
with Noise_Nugget_SDK.Audio.I2S;

package body Noise_Nugget_SDK.Audio is

   -----------
   -- Start --
   -----------

   function Start (Callback : Audio_Callback) return Boolean is
   begin
      if not I2S.Initialize (Callback) then
         return False;
      end if;

      return WM8960.Initialize;
   end Start;

   -------------------
   -- Set_HP_Volume --
   -------------------

   procedure Set_HP_Volume (L, R : Audio_Volume) is
   begin
      WM8960.Set_HP_Volume (L, R);
   end Set_HP_Volume;

end Noise_Nugget_SDK.Audio;
