with RP.Clock;
with RP.GPIO;
with RP.PWM;
with RP.Multicore.FIFO;
with RP.Multicore.Spinlocks;
with RP2040_SVD.SIO;
with Noise_Nugget_Sdk_Config; use Noise_Nugget_Sdk_Config;

package body Noise_Nugget_SDK is
begin
   RP.Clock.Initialize
     (XOSC_Frequency,
      SYS_PLL_Config => (case Noise_Nugget_Sdk_Config.System_Clock is
                            when SYS_48MHz  => RP.Clock.PLL_48_MHz,
                            when SYS_125MHz => RP.Clock.PLL_125_MHz,
                            when SYS_133MHz => RP.Clock.PLL_133_MHz,
                            when SYS_250MHz => RP.Clock.PLL_250_MHz));

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
