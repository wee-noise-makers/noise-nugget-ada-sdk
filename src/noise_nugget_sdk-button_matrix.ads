with Noise_Nugget_SDK.Button_Matrix_Definition;

generic
   with package Definition
     is new Noise_Nugget_SDK.Button_Matrix_Definition (<>);

   Column_Pins    : Definition.Column_Pin_Array;
   Row_Pins       : Definition.Row_Pin_Array;
   Mapping        : Definition.Button_Mapping_Array;
package Noise_Nugget_SDK.Button_Matrix is

   procedure Update;

   function State return Definition.Button_Pressed_Array;

   function Events return Definition.Button_Event_Array;

end Noise_Nugget_SDK.Button_Matrix;
