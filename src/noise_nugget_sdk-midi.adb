with System;

with Cortex_M.NVIC;

with MIDI.Decoder.Queue;
with MIDI.Encoder.Queue;

with RP.UART;
with RP.GPIO; use RP.GPIO;
with RP_Interrupts;
with RP2040_SVD.Interrupts;

with HAL; use HAL;

with BBqueue;         use BBqueue;
with BBqueue.Buffers; use BBqueue.Buffers;

package body Noise_Nugget_SDK.MIDI is

   Decoder_Queue : Standard.MIDI.Decoder.Queue.Instance (Capacity => 256);
   Encoder_Queue : Standard.MIDI.Encoder.Queue.Instance (Capacity => 1024);

   Out_Grant : BBqueue.Buffers.Read_Grant;

   UART           : RP.UART.UART_Port renames RP.Device.UART_0;
   DMA_TX_Trigger : constant RP.DMA.DMA_Request_Trigger := RP.DMA.UART0_TX;
   UART_TX        : RP.GPIO.GPIO_Point := (Pin => 12);
   UART_RX        : RP.GPIO.GPIO_Point := (Pin => 13);

   procedure UART0_RX_Handler;

   ----------------------
   -- UART0_RX_Handler --
   ----------------------

   procedure UART0_RX_Handler is
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

      --  UART0.Clear_IRQ (RP.UART.Receive);
   end UART0_RX_Handler;

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

      RP_Interrupts.Attach_Handler (UART0_RX_Handler'Access,
                                    RP2040_SVD.Interrupts.UART0_Interrupt,
                                    System.Interrupt_Priority'First);
      Cortex_M.NVIC.Enable_Interrupt (RP2040_SVD.Interrupts.UART0_Interrupt);
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
