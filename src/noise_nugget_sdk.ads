private with RP.DMA;
private with RP.PIO;
private with RP.Device;

package Noise_Nugget_SDK
with Elaborate_Body
is

private

   use RP.DMA;

   ------------------------
   -- Pio_Rotary_Encoder --
   ------------------------

   Pio_Rotary_Encoder_Wrap_Target : constant := 0;
   Pio_Rotary_Encoder_Wrap        : constant := 23;

   Pio_Rotary_Encoder_Program_Instructions : RP.PIO.Program :=
     (
      --             .wrap_target
      16#0011#,  --   0: jmp    17              side 0
      16#0015#,  --   1: jmp    21              side 0
      16#0017#,  --   2: jmp    23              side 0
      16#0011#,  --   3: jmp    17              side 0
      16#0011#,  --   4: jmp    17              side 0
      16#0011#,  --   5: jmp    17              side 0
      16#0011#,  --   6: jmp    17              side 0
      16#0011#,  --   7: jmp    17              side 0
      16#0011#,  --   8: jmp    17              side 0
      16#0011#,  --   9: jmp    17              side 0
      16#0011#,  --  10: jmp    17              side 0
      16#0011#,  --  11: jmp    17              side 0
      16#0011#,  --  12: jmp    17              side 0
      16#0017#,  --  13: jmp    23              side 0
      16#0015#,  --  14: jmp    21              side 0
      16#0011#,  --  15: jmp    17              side 0
      16#4002#,  --  16: in     pins, 2         side 0
      16#a0e6#,  --  17: mov    osr, isr        side 0
      16#60c2#,  --  18: out    isr, 2          side 0
      16#4802#,  --  19: in     pins, 2         side 1
      16#a086#,  --  20: mov    exec, isr       side 0
      16#d010#,  --  21: irq    nowait 0 rel    side 2
      16#0011#,  --  22: jmp    17              side 0
      16#d012#); --  23: irq    nowait 2 rel    side 2
      --             .wrap

   XOSC_Frequency : constant := 12_000_000;

   I2S_OUT_DMA_IRQ : constant RP.DMA.DMA_IRQ_Id := 0;
   I2S_IN_DMA_IRQ : constant RP.DMA.DMA_IRQ_Id := 1;

   -- PIO 0 --

   Encoder_PIO    :          RP.PIO.PIO_Device renames RP.Device.PIO_0;
   Encoder_1_SM   : constant RP.PIO.PIO_SM := 0;
   Encoder_2_SM   : constant RP.PIO.PIO_SM := 1;
   Encoder_1_IRQ  : constant RP.PIO.PIO_IRQ_ID := 0;
   Encoder_2_IRQ  : constant RP.PIO.PIO_IRQ_ID := 1;
   Encoder_Offset : constant RP.PIO.PIO_Address := 0;
   Encoder_Last   : constant RP.PIO.PIO_Address :=
     Encoder_Offset + Pio_Rotary_Encoder_Program_Instructions'Length - 1;

   WS2812_PIO    :          RP.PIO.PIO_Device renames RP.Device.PIO_0;
   WS2812_SM     : constant RP.PIO.PIO_SM := 2;
   WS2812_Offset : constant RP.PIO.PIO_Address := Encoder_Last + 1;

   -- PIO 1 --

   I2S_PIO    :          RP.PIO.PIO_Device renames RP.Device.PIO_1;
   I2S_SM     : constant RP.PIO.PIO_SM := 0;
   I2S_Offset : constant RP.PIO.PIO_Address := 0;

   I2S_OUT_DMA_Trigger : constant RP.DMA.DMA_Request_Trigger :=
     RP.DMA.PIO1_TX0;
   I2S_IN_DMA_Trigger  : constant RP.DMA.DMA_Request_Trigger :=
     RP.DMA.PIO1_RX0;

   WS2812_Used : Boolean := False;
   --  Because of limited resources (DMA, PIO state machines) the WS2812
   --  generic package can only be instantiated once. The only way I found
   --  to check this is at run-time.

   -- DMA --

   I2S_OUT_DMA      : constant RP.DMA.DMA_Channel_Id := 0;
   I2S_IN_DMA       : constant RP.DMA.DMA_Channel_Id := I2S_OUT_DMA + 1;
   WS2812_DMA       : constant RP.DMA.DMA_Channel_Id := I2S_IN_DMA + 1;
   MIDI_UART_TX_DMA : constant RP.DMA.DMA_Channel_Id := WS2812_DMA + 1;
   Screen_SPI_DMA   : constant RP.DMA.DMA_Channel_Id := MIDI_UART_TX_DMA + 1;

end Noise_Nugget_SDK;
