with System;

with Cortex_M.NVIC;

with MIDI.Decoder.Queue;
with MIDI.Encoder.Queue;

with RP.GPIO; use RP.GPIO;

with HAL; use HAL;

with BBqueue;         use BBqueue;
with BBqueue.Buffers; use BBqueue.Buffers;

package body Noise_Nugget_SDK.MIDI is

   Decoder_Queue : Standard.MIDI.Decoder.Queue.Instance
     (Decoder_Queue_Capacity);

   Encoder_Queue : Standard.MIDI.Encoder.Queue.Instance
     (Encoder_Queue_Capacity);

   Out_Grant : BBqueue.Buffers.Read_Grant;

   UART_TX        : RP.GPIO.GPIO_Point := (Pin => TX_Pin);
   UART_RX        : RP.GPIO.GPIO_Point := (Pin => RX_Pin);

   procedure UART_RX_Handler;

   ---------------------
   -- UART_RX_Handler --
   ---------------------

   procedure UART_RX_Handler is
   begin

      case UART.Receive_Status is

         when RP.UART.Not_Full | RP.UART.Full =>
            declare
               FIFO : UInt32 with Address => UART.FIFO_Address;
            begin
               Standard.MIDI.Decoder.Queue.Push (Decoder_Queue,
                                                 UInt8 (FIFO and 16#FF#));
            end;

         when RP.UART.Empty | RP.UART.Busy =>
            --  Impossible?
            null;

         when RP.UART.Invalid =>
            raise Program_Error;

      end case;

      --  UART.Clear_IRQ (RP.UART.Receive);
   end UART_RX_Handler;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      UART_TX.Configure (Output, Pull_Up, RP.GPIO.UART);

      UART_RX.Configure (Output, Floating, RP.GPIO.UART);

      UART.Configure
        (Config =>
           (Baud      => 31_250,
            Word_Size => 8,
            Parity    => False,
            Stop_Bits => 1,
            Enable_FIFOs => False,
            others    => <>));

      -- DMA --
      declare
         Config : DMA_Configuration;
      begin
         Config.Trigger := DMA_TX_Trigger;
         Config.High_Priority := True;
         Config.Data_Size := Transfer_8;
         Config.Increment_Read := True;
         Config.Increment_Write := False;

         RP.DMA.Configure (MIDI_UART_TX_DMA, Config);
      end;

      UART.Enable_IRQ (RP.UART.Receive);
      UART.Set_FIFO_IRQ_Level (RX => RP.UART.Lvl_Eighth,
                               TX => RP.UART.Lvl_Eighth);

      RP_Interrupts.Attach_Handler (UART_RX_Handler'Unrestricted_Access,
                                    UART_Interrupt,
                                    System.Interrupt_Priority'First);
      Cortex_M.NVIC.Enable_Interrupt (UART_Interrupt);
   end Initialize;

   ----------
   -- Send --
   ----------

   procedure Send (Msg : Standard.MIDI.Message) is
   begin
      Standard.MIDI.Encoder.Queue.Push (Encoder_Queue, Msg);
   end Send;

   ------------------
   -- Flush_Output --
   ------------------

   procedure Flush_Output is
   begin
      if RP.DMA.Busy (MIDI_UART_TX_DMA) then
         --  Previous DMA transfer still in progress
         return;
      end if;

      if State (Out_Grant) = Valid then
         --  Release the previous grant
         Encoder_Queue.Release (Out_Grant);
      end if;

      --  Try to get a new grant
      Encoder_Queue.Read (Out_Grant);

      if State (Out_Grant) = Valid then

         --  If we have a new grant, start DMA transfer

         RP.DMA.Start (Channel => MIDI_UART_TX_DMA,
                       From    => Slice (Out_Grant).Addr,
                       To      => UART.FIFO_Address,
                       Count   => UInt32 (Slice (Out_Grant).Length));
      end if;

   end Flush_Output;

   ---------------
   -- Get_Input --
   ---------------

   procedure Get_Input (Msg     : out Standard.MIDI.Message;
                        Success : out Boolean)
   is
   begin
      Standard.MIDI.Decoder.Queue.Pop (Decoder_Queue, Msg, Success);
   end Get_Input;

   ----------------------------
   -- For_Each_Input_Message --
   ----------------------------

   procedure For_Each_Input_Message is
      procedure Flush
      is new Standard.MIDI.Decoder.Queue.Flush (Handle_Message);
   begin
      Flush (Decoder_Queue);
   end For_Each_Input_Message;

begin
   Initialize;
end Noise_Nugget_SDK.MIDI;
