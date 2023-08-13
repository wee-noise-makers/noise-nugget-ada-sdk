with RP.GPIO;

generic
   Column_Count : Positive;
   Row_Count : Positive;
package Noise_Nugget_SDK.Button_Matrix_Definition is

   type Column_Range is new Positive range 1 .. Column_Count;
   type Row_Range is new Positive range 1 .. Row_Count;

   type Column_Pin_Array is array (Column_Range) of RP.GPIO.GPIO_Pin;
   type Row_Pin_Array is array (Row_Range) of RP.GPIO.GPIO_Pin;

   type Button_Pressed_Array is array (Column_Range, Row_Range) of Boolean;
end Noise_Nugget_SDK.Button_Matrix_Definition;
