with MIDI;

with RP.Timer; use RP.Timer;

with Noise_Nugget_SDK.Audio;

with System.Storage_Elements;
with Synth;
with Tresses.Resources;

package body CPU_Core_1 is

   Scartch_X_Size  : constant := 4 * 1024;
   Scartch_X_Start : constant := 16#20040000#;
   Scartch_X_End   : constant := Scartch_X_Start + Scartch_X_Size;

   procedure Main;

   Vector : Integer;
   pragma Import (C, Vector, "__vectors");

   -----------------
   -- Trap_Vector --
   -----------------

   function Trap_Vector return HAL.UInt32
   is (HAL.UInt32 (System.Storage_Elements.To_Integer (Vector'Address)));

   -------------------
   -- Stack_Pointer --
   -------------------

   function Stack_Pointer return HAL.UInt32
   is (Scartch_X_End);

   -----------------
   -- Entry_Point --
   -----------------

   function Entry_Point return HAL.UInt32
   is (HAL.UInt32 (System.Storage_Elements.To_Integer (Main'Address)));

   ----------
   -- Main --
   ----------

   procedure Main is
      use MIDI;

      Key : MIDI.MIDI_Key := MIDI.C4;
      Next_Key : Time := Clock + Milliseconds (50);
      On : Boolean := False;

   begin
      if not Noise_Nugget_SDK.Audio.Start
        (Tresses.Resources.SAMPLE_RATE,
         Output_Callback => Synth.Output_Callback'Access,
         Input_Callback  => Synth.Input_Callback'Access)
      then
         raise Program_Error with "MDM";
      end if;

      Noise_Nugget_SDK.Audio.Set_HP_Volume (0.7, 0.7);
      Noise_Nugget_SDK.Audio.Set_Line_Volume (1, 1.0, 0.0);
      Noise_Nugget_SDK.Audio.Set_Line_Volume (2, 1.0, 1.0);
      Noise_Nugget_SDK.Audio.Set_Line_Volume (3, 1.0, 1.0);
      Noise_Nugget_SDK.Audio.Enable_Mic (True, True);
      Noise_Nugget_SDK.Audio.Set_ADC_Volume (0.6, 0.6);
      Noise_Nugget_SDK.Audio.Mixer_To_Output (False, False);

      loop
         Synth.Update_Buffer;

         if not Synth.Got_MIDI_Input and then Next_Key < Clock then
            Next_Key := Next_Key + Milliseconds (10);

            if On then
               Synth.Note_Off (Key);
            else

               Synth.Note_On (Key, 127);

               if Key < MIDI.C4 then
                  Key := Key + 1;
               else
                  Key := MIDI.C1;
               end if;
            end if;

            On := not On;
         end if;
      end loop;
   end Main;

end CPU_Core_1;
