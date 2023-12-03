with RP.PIO.WS2812;

package body Noise_Nugget_SDK.WS2812 is

   LED_Pin : aliased RP.GPIO.GPIO_Point := (Pin => Pin);

   Strip : aliased RP.PIO.WS2812.Strip (LED_Pin'Access,
                                        WS2812_PIO'Access,
                                        WS2812_SM,
                                        Number_Of_LEDs);
   -----------
   -- Clear --
   -----------

   procedure Clear is
   begin
      Strip.Clear;
   end Clear;

   -------------
   -- Set_RGB --
   -------------

   procedure Set_RGB (Id      : LED_Id;
                      R, G, B : HAL.UInt8)
   is
   begin
      Strip.Set_RGB (Positive (Id), R, G, B);
   end Set_RGB;

   -------------
   -- Set_RGB --
   -------------

   procedure Set_RGB (Id  : LED_Id;
                      RGB : RGB_Rec)
   is
   begin
      Strip.Set_RGB (Positive (Id), RGB.R, RGB.G, RGB.B);
   end Set_RGB;

   -------------
   -- Set_Hue --
   -------------

   procedure Set_Hue (Id  : LED_Id;
                      H   : Hue)
   is
   begin
      Set_RGB (Id, Hue_To_RGB (H));
   end Set_Hue;

   -------------
   -- Set_HSV --
   -------------

   procedure Set_HSV (Id      : LED_Id;
                      H, S, V : HAL.UInt8)
   is
   begin
      Strip.Set_HSV (Positive (Id), H, S, V);
   end Set_HSV;

   ------------
   -- Update --
   ------------

   procedure Update (Blocking : Boolean := False) is
   begin
      Strip.Update (Blocking);
   end Update;

begin

   if not WS2812_Used then
      Strip.Initialize (WS2812_Offset);
      Strip.Enable_DMA (WS2812_DMA);

      WS2812_Used := True;
   else
      raise Program_Error with "Max number of WS2812 strip reached";
   end if;

end Noise_Nugget_SDK.WS2812;
