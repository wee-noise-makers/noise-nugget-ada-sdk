with RP.GPIO;

package body Noise_Nugget_SDK.Button_Matrix is

   use Definition;

   Column_Points : array (Column_Range) of RP.GPIO.GPIO_Point;
   Row_Points : array (Row_Range) of RP.GPIO.GPIO_Point;

   type Pin_Low_Array is array (Column_Range, Row_Range) of Boolean;

   Last_State : Definition.Button_Pressed_Array :=
     (others => False);
   Prev_State : Definition.Button_Pressed_Array :=
     (others => False);
   Last_Events : Definition.Button_Event_Array :=
     (others => Up);

   ------------
   -- Update --
   ------------

   procedure Update is
      Busy : Integer := 0
        with Volatile;

      Pin_State : Pin_Low_Array;
   begin
      for Col in Column_Range loop
         Column_Points (Col).Set;

         --  Short buzy loop to wait for the column to be set
         for X in 1 .. 50 loop
            Busy := X;
         end loop;

         for Row in Row_Range loop
            Pin_State (Col, Row) := Row_Points (Row).Set;
         end loop;

         Column_Points (Col).Clear;
      end loop;

      Prev_State := Last_State;
      for B in Definition.Button_Id_Type loop
         Last_State (B) := Pin_State (Mapping (B).Col, Mapping (B).Row);
         if Last_State (B) = Prev_State (B) then
            Last_Events (B) := (if Last_State (B) then Down else Up);
         else
            Last_Events (B) := (if Last_State (B) then Falling else Rising);
         end if;
      end loop;

   end Update;

   -----------
   -- State --
   -----------

   function State return Definition.Button_Pressed_Array is
   begin
      return Last_State;
   end State;

   ------------
   -- Events --
   ------------

   function Events return Definition.Button_Event_Array is
   begin
      return Last_Events;
   end Events;

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
