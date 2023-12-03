with RP.GPIO;

package body Noise_Nugget_SDK.Button_Matrix is

   use Definition;

   Column_Points : array (Column_Range) of RP.GPIO.GPIO_Point;
   Row_Points : array (Row_Range) of RP.GPIO.GPIO_Point;

   Last_State : Definition.Button_Pressed_Array :=
     (others => (others => False));

   ------------
   -- Update --
   ------------

   procedure Update is
      Busy : Integer := 0
        with Volatile;
   begin
      for Col in Column_Range loop
         Column_Points (Col).Set;

         --  Short buzy loop to wait for the column to be set
         for X in 1 .. 50 loop
            Busy := X;
         end loop;

         for Row in Row_Range loop
            Last_State (Col, Row) := Row_Points (Row).Set;
         end loop;

         Column_Points (Col).Clear;
      end loop;
   end Update;

   -----------
   -- State --
   -----------

   function State return Definition.Button_Pressed_Array is
   begin
      return Last_State;
   end State;

begin

   for Col in Column_Range loop
      Column_Points (Col).Pin := Column_Pins (Col);
      Column_Points (Col).Configure (RP.GPIO.Output);
      Column_Points (Col).Clear;
   end loop;

   for Row in Row_Range loop
      Row_Points (Row).Pin := Row_Pins (Row);
      Row_Points (Row).Configure (RP.GPIO.Input, RP.GPIO.Pull_Down);
   end loop;

end Noise_Nugget_SDK.Button_Matrix;
