with RP.GPIO;

generic
   Column_Count : Positive;
   Row_Count    : Positive;
   type Button_Id_Type is (<>);

package Noise_Nugget_SDK.Button_Matrix_Definition is

   type Column_Range is new Positive range 1 .. Column_Count;
   type Row_Range is new Positive range 1 .. Row_Count;

   type Column_Pin_Array is array (Column_Range) of RP.GPIO.GPIO_Pin;
   type Row_Pin_Array is array (Row_Range) of RP.GPIO.GPIO_Pin;

   type Button_Pressed_Array is array (Button_Id_Type) of Boolean;
   type Button_Event_Array is array (Button_Id_Type) of Button_Event;

   type Pin_Map is record
      Col : Column_Range;
      Row : Row_Range;
   end record;

   type Button_Mapping_Array is array (Button_Id_Type) of Pin_Map;

end Noise_Nugget_SDK.Button_Matrix_Definition;
