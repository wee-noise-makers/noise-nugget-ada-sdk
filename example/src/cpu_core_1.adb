with MIDI;

with RP.Timer; use RP.Timer;

with Noise_Nugget_SDK.Audio;

with System.Storage_Elements;
with Synth;

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
   begin
      if not Noise_Nugget_SDK.Audio.Start (Synth.Callback'Access) then
         raise Program_Error with "MDM";
      end if;

      Noise_Nugget_SDK.Audio.Set_HP_Volume (0.7, 0.7);
      loop
         for Key in MIDI.C1 .. MIDI.C4 loop
            exit when Synth.Got_MIDI_Input;
            Synth.Note_On (Key, 127);
            Busy_Wait_Until (Clock + Milliseconds (100));
            Synth.Note_Off (Key);
            Busy_Wait_Until (Clock + Milliseconds (100));
         end loop;
         exit when Synth.Got_MIDI_Input;
      end loop;

      loop
         null;
      end loop;
   end Main;

end CPU_Core_1;
