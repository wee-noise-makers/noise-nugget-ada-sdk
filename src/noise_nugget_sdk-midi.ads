with MIDI;

package Noise_Nugget_SDK.MIDI is

   procedure Send (Msg : Standard.MIDI.Message);

   procedure Flush_Output;

   generic
      with procedure Handle_Message (Msg : Standard.MIDI.Message);
   procedure For_Each_Input_Message;
   --  Instantiate this procedure with a sub-program to handle decoded
   --  messages. When calling For_Each_Input_Message, the sub-program
   --  Handle_Message will be called for each message received since the
   --  last call of For_Each_Input_Message.

end Noise_Nugget_SDK.MIDI;
