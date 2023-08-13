with Font_5x7;
with Noise_Nugget_SDK.Screen.SSD1306;

package body Bitmap_Font is

   package Screen renames Noise_Nugget_SDK.Screen.SSD1306;

   -----------
   -- Print --
   -----------

   procedure Print
     (X_Offset    : in out Integer;
      Y_Offset    : Integer;
      C           : Character)
   is
      Index : constant Integer := Character'Pos (C) - Character'Pos ('!');
      Bitmap_Offset : constant Integer := Index * 5;

      function Color (X, Y : Integer) return Boolean;

      -----------
      -- Color --
      -----------

      function Color (X, Y : Integer) return Boolean is
         type Bit_Array is array (Positive range <>) of Boolean
           with Pack;

         Data : Bit_Array (1 .. Font_5x7.Data.W * Font_5x7.Data.H)
           with Address => Font_5x7.Data.Data'Address;

      begin
         if Index in 0 .. 93 and then X in 0 .. 4 and then Y in 0 .. 6 then
            return not Data (1 + X + Bitmap_Offset + Y * Font_5x7.Data.W);
         else
            return False;
         end if;
      end Color;

   begin
      Draw_Loop : for X in 0 .. 5 loop
         for Y in 0 .. 6 loop

            if Y + Y_Offset in 0 .. Screen.Height - 1 then
               if X + X_Offset > Screen.Width - 1 then
                  exit Draw_Loop;
               elsif X + X_Offset >= 0
                 and then
                   Y + Y_Offset in 0 .. Screen.Height - 1
               then
                  Screen.Set_Pixel (Screen.Pix_X (X + X_Offset),
                                    Screen.Pix_Y (Y + Y_Offset),
                                    Color (X, Y));
               end if;
            end if;
         end loop;
      end loop Draw_Loop;

      X_Offset := X_Offset + Width;
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (X_Offset    : in out Integer;
      Y_Offset    : Integer;
      Str         : String)
   is
   begin
      for C of Str loop
         if X_Offset > Screen.Width then
            return;
         end if;
         Print (X_Offset, Y_Offset, C);
      end loop;
   end Print;

end Bitmap_Font;
