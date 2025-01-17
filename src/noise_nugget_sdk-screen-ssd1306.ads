with RP.SPI;
with RP.DMA;
with RP.GPIO;

generic
   SPI         : not null access RP.SPI.SPI_Port;
   DMA_Trigger : RP.DMA.DMA_Request_Trigger;
   N_Reset_Pin : RP.GPIO.GPIO_Pin;
   DC_Pin      : RP.GPIO.GPIO_Pin;
   SCK_Pin     : RP.GPIO.GPIO_Pin; -- D0
   MOSI_Pin    : RP.GPIO.GPIO_Pin; -- D1
package Noise_Nugget_SDK.Screen.SSD1306 is

   --  Right now this package only supports 128x64 SSD1306 OLED screen.

   Width : constant := 128;
   Height : constant := 64;

   type Pix_X is range 0 .. Width - 1;
   type Pix_Y is range 0 .. Height - 1;

   procedure Set_Pixel (PX : Pix_X; PY : Pix_Y; On : Boolean := True);
   procedure Update;
   procedure Clear;

end Noise_Nugget_SDK.Screen.SSD1306;
