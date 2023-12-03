with HAL;
with RP.GPIO;

generic
   Pin : RP.GPIO.GPIO_Pin;
   Number_Of_LEDs : Positive;
package Noise_Nugget_SDK.WS2812 is

   type LED_Id is new Positive range 1 .. Number_Of_LEDs;

   type RGB_Rec is record
      R, G, B : HAL.UInt8;
   end record;

   type Hue is (White, Red, Rose, Magenta, Violet, Blue, Azure, Cyan,
                Spring_Green, Green, Chartreuse, Yellow, Orange);
   --  A set of good looking colors for RGB LEDs

   procedure Clear;
   --  Turn off all LEDs

   procedure Set_RGB (Id      : LED_Id;
                      R, G, B : HAL.UInt8);

   procedure Set_RGB (Id  : LED_Id;
                      RGB : RGB_Rec);

   procedure Set_Hue (Id  : LED_Id;
                      H   : Hue);

   procedure Set_HSV (Id      : LED_Id;
                      H, S, V : HAL.UInt8);

   procedure Update (Blocking : Boolean := False);

   Hue_To_RGB : constant array (Hue) of RGB_Rec :=
     (White        => (255, 255, 255),
      Red          => (255, 000, 000),
      Rose         => (255, 000, 128),
      Magenta      => (255, 000, 255),
      Violet       => (128, 000, 255),
      Blue         => (000, 000, 255),
      Azure        => (000, 128, 255),
      Cyan         => (000, 255, 255),
      Spring_Green => (000, 255, 128),
      Green        => (000, 255, 000),
      Chartreuse   => (128, 255, 000),
      Yellow       => (255, 255, 000),
      Orange       => (255, 128, 000));

end Noise_Nugget_SDK.WS2812;
