with System;

with RP.GPIO; use RP.GPIO;

with Atomic.Signed;

with RP.PIO; use RP.PIO;
with RP_Interrupts;
with RP2040_SVD.Interrupts;

package body Noise_Nugget_SDK.Encoders is

   package Atomic_Int is new Atomic.Signed (Integer);

   Program_Loaded : Boolean := False;
   Val_1 : aliased Atomic_Int.Instance;
   Val_2 : aliased Atomic_Int.Instance;

   -----------------------
   -- PIO0_IRQ0_Handler --
   -----------------------

   procedure PIO0_IRQ0_Handler is
   begin
      if Encoder_PIO.SM_IRQ_Status (0) then
         Atomic_Int.Sub (Val_1, 1);
         Encoder_PIO.Ack_SM_IRQ (0);
      elsif Encoder_PIO.SM_IRQ_Status (2) then
         Atomic_Int.Add (Val_1, 1);
         Encoder_PIO.Ack_SM_IRQ (2);
      end if;
   end PIO0_IRQ0_Handler;

   -----------------------
   -- PIO0_IRQ1_Handler --
   -----------------------

   procedure PIO0_IRQ1_Handler is
   begin
      if Encoder_PIO.SM_IRQ_Status (1) then
         Atomic_Int.Sub (Val_2, 1);
         Encoder_PIO.Ack_SM_IRQ (1);
      elsif Encoder_PIO.SM_IRQ_Status (3) then
         Atomic_Int.Add (Val_2, 1);
         Encoder_PIO.Ack_SM_IRQ (3);
      end if;
   end PIO0_IRQ1_Handler;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Id : Encoder_Id; Low_Pin : RP.GPIO.GPIO_Pin) is
      A : RP.GPIO.GPIO_Point := (Pin => Low_Pin);
      B : RP.GPIO.GPIO_Point := (Pin => Low_Pin + 1);

      IRQ : constant RP.PIO.PIO_IRQ_ID := (case Id is
                                              when 1 => Encoder_1_IRQ,
                                              when 2 => Encoder_2_IRQ);

      SM  : constant RP.PIO.PIO_SM := (case Id is
                                          when 1 => Encoder_1_SM,
                                          when 2 => Encoder_2_SM);

      Config : PIO_SM_Config := Default_SM_Config;
   begin
      pragma Compile_Time_Error (Encoder_1_SM /= 0, "Encoder 1 must use SM0");
      pragma Compile_Time_Error (Encoder_2_SM /= 1, "Encoder 2 must use SM1");

      A.Configure (Input, Pull_Up, Encoder_PIO.GPIO_Function);
      B.Configure (Input, Pull_Up, Encoder_PIO.GPIO_Function);

      if not Program_Loaded then
         Encoder_PIO.Load (Pio_Rotary_Encoder_Program_Instructions,
                           Offset => Encoder_Offset);
         Program_Loaded := True;
      end if;

      Set_In_Shift (Config,
                    Shift_Right    => False,
                    Autopush       => False,
                    Push_Threshold => 32);

      Set_Wrap (Config,
                Encoder_Offset + Pio_Rotary_Encoder_Wrap_Target,
                Encoder_Offset + Pio_Rotary_Encoder_Wrap);

      Set_Clock_Frequency (Config, 5_000);

      Set_In_Pins (Config, A.Pin);

      Encoder_PIO.SM_Initialize (SM, Encoder_Offset + 16, Config);

      case Id is
         when 1 =>
            RP_Interrupts.Attach_Handler
              (PIO0_IRQ0_Handler'Access,
               RP2040_SVD.Interrupts.PIO0_IRQ_0_Interrupt,
               System.Interrupt_Priority'Last);

            --  Enable SM IRQ flags 0 and 2 for the SM 0 on PIO IRQ line 0
            --  (see pio_rotary_encoder.pio).
            Encoder_PIO.Enable_IRQ_Flag (IRQ, SM_IRQ0);
            Encoder_PIO.Enable_IRQ_Flag (IRQ, SM_IRQ2);

         when 2 =>
            RP_Interrupts.Attach_Handler
              (PIO0_IRQ1_Handler'Access,
               RP2040_SVD.Interrupts.PIO0_IRQ_1_Interrupt,
               System.Interrupt_Priority'Last);

            --  Enable SM IRQ flags 1 and 3 for the SM 1 on PIO IRQ line 1
            --  (see pio_rotary_encoder.pio).
            Encoder_PIO.Enable_IRQ_Flag (IRQ, SM_IRQ1);
            Encoder_PIO.Enable_IRQ_Flag (IRQ, SM_IRQ3);
      end case;

      Encoder_PIO.Enable_IRQ (IRQ);
      Encoder_PIO.SM_Initialize (SM, Encoder_Offset + 16, Config);
      Encoder_PIO.Set_Enabled (SM, True);
   end Initialize;

   -----------------
   -- Delta_Value --
   -----------------

   function Delta_Value (Id : Encoder_Id) return Integer is
      Res : Integer;
   begin
      case Id is
         when 1 =>
            --  Load and reset
            Atomic_Int.Exchange (Val_1, 0, Res);
         when 2 =>
            --  Load and reset
            Atomic_Int.Exchange (Val_2, 0, Res);
      end case;

      return Res;
   end Delta_Value;

end Noise_Nugget_SDK.Encoders;
