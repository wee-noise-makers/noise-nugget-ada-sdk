with HAL;
with RP.GPIO;

generic
   Pin : RP.GPIO.GPIO_Pin;
   Number_Of_LEDs : Positive;
package Noise_Nugget_SDK.WS2812 is

   type LED_Id is new Positive range 1 .. Number_Of_LEDs;

   procedure Clear;
   --  Turn off all LEDs

   procedure Set_RGB (Id      : LED_Id;
                      R, G, B : HAL.UInt8);

   procedure Set_HSV (Id      : LED_Id;
                      H, S, V : HAL.UInt8);

   procedure Update (Blocking : Boolean := False);

end Noise_Nugget_SDK.WS2812;
