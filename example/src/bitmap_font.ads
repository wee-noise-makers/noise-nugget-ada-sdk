
package Bitmap_Font is

   Width : constant := 6;
   Height : constant := 8;

   procedure Print (X_Offset    : in out Integer;
                    Y_Offset    : Integer;
                    C           : Character);

   procedure Print (X_Offset    : in out Integer;
                    Y_Offset    : Integer;
                    Str         : String);

end Bitmap_Font;
