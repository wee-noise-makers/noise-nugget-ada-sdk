with System.Storage_Elements;
with MIDI;
with RP.UART;
with RP.DMA;
with RP.GPIO;
with RP_Interrupts;

generic
   UART           : not null access RP.UART.UART_Port;
   UART_Interrupt : RP_Interrupts.Interrupt_ID;
   DMA_TX_Trigger : RP.DMA.DMA_Request_Trigger;
   TX_Pin         : RP.GPIO.GPIO_Pin;
   RX_Pin         : RP.GPIO.GPIO_Pin;

   Decoder_Queue_Capacity : System.Storage_Elements.Storage_Count := 256;
   Encoder_Queue_Capacity : System.Storage_Elements.Storage_Count := 1024;
package Noise_Nugget_SDK.MIDI is

   procedure Send (Msg : Standard.MIDI.Message);

   procedure Flush_Output;

   procedure Get_Input (Msg     : out Standard.MIDI.Message;
                        Success : out Boolean);

   generic
      with procedure Handle_Message (Msg : Standard.MIDI.Message);
   procedure For_Each_Input_Message;
   --  Instantiate this procedure with a sub-program to handle decoded
   --  messages. When calling For_Each_Input_Message, the sub-program
   --  Handle_Message will be called for each message received since the
   --  last call of For_Each_Input_Message.

end Noise_Nugget_SDK.MIDI;
