with RP.GPIO;

package Noise_Nugget_SDK.Encoders is

   type Encoder_Id is range 1 .. 2;

   procedure Initialize (Id : Encoder_Id; Low_Pin : RP.GPIO.GPIO_Pin);
   --  A and B signals from the encoder must be connected to consecutive
   --  pins on the Noise Nugget (e.g. 9 and 10, 26 and 27, etc.). The
   --  Low_Pin argument must be the lowest pin of the two.

   function Delta_Value (Id : Encoder_Id) return Integer;
   --  Count of indents since the last call, positive or negative depending on
   --  the direction.

end Noise_Nugget_SDK.Encoders;
