with RP.Clock;
with RP.GPIO;
with RP.PWM;
with RP.Multicore.FIFO;
with RP.Multicore.Spinlocks;
with RP2040_SVD.SIO;

package body Noise_Nugget_SDK is

begin
   RP.Clock.Initialize (XOSC_Frequency,
                        SYS_PLL_Config => RP.Clock.PLL_250_MHz);
   RP.Device.PIO_0.Enable;
   RP.Device.PIO_1.Enable;
   RP.Device.Timer.Enable;
   RP.GPIO.Enable;
   RP.DMA.Enable;
   RP.PWM.Initialize;

   --  Make sure we don't have data left in the FIFO after reset
   RP.Multicore.FIFO.Drain;

   --  Clear FIFO Status
   RP2040_SVD.SIO.SIO_Periph.FIFO_ST := (others => <>);

   --  Make sure we don't have spinlocks locked after reset
   for Id in RP.Multicore.Spinlocks.Lock_Id loop
      RP.Multicore.Spinlocks.Release (Id);
   end loop;


end Noise_Nugget_SDK;
