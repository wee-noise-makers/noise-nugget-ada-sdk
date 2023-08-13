with RP.GPIO;

package Noise_Nugget_SDK.Screen.SSD1306 is

   --  Right now this package only supports 128x64 SSD1306 OLED screen
   --  connected to pins 8, 9, 10, and 11.

   Width : constant := 128;
   Height : constant := 64;

   type Pix_X is range 0 .. Width - 1;
   type Pix_Y is range 0 .. Height - 1;

   procedure Set_Pixel (PX : Pix_X; PY : Pix_Y; On : Boolean := True);
   procedure Update;
   procedure Clear;

end Noise_Nugget_SDK.Screen.SSD1306;
