private with RP.DMA;
private with RP.PIO;
private with RP.Device;

package Noise_Nugget_SDK
with Elaborate_Body
is

private
   XOSC_Frequency : constant := 12_000_000;

   I2S_OUT_DMA      : constant RP.DMA.DMA_Channel_Id := 0;
   I2S_IN_DMA       : constant RP.DMA.DMA_Channel_Id := 1;
   MIDI_UART_TX_DMA : constant RP.DMA.DMA_Channel_Id := 2;

   -- PIO 1 --

   I2S_PIO    : RP.PIO.PIO_Device renames RP.Device.PIO_1;
   I2S_SM     : constant RP.PIO.PIO_SM := 0;
   I2S_Offset : constant RP.PIO.PIO_Address := 0;
   I2S_OUT_DMA_Trigger : constant RP.DMA.DMA_Request_Trigger :=
     RP.DMA.PIO1_TX0;
   I2S_IN_DMA_Trigger  : constant RP.DMA.DMA_Request_Trigger :=
     RP.DMA.PIO1_RX0;

end Noise_Nugget_SDK;
