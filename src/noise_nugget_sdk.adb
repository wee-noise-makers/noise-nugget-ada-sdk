with RP.Clock;
with RP.GPIO;
with RP.PWM;

package body Noise_Nugget_SDK is

begin
   RP.Clock.Initialize (XOSC_Frequency);
   RP.Device.PIO_0.Enable;
   RP.Device.PIO_1.Enable;
   RP.GPIO.Enable;
   RP.DMA.Enable;
   RP.PWM.Initialize;

end Noise_Nugget_SDK;
