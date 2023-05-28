with Tresses; use Tresses;
with Tresses.Macro;
with Tresses.FX.Reverb;

with MIDI;
with Noise_Nugget_SDK.MIDI;

package body Synth is

   We_Got_MIDI_Input : Boolean := False
     with Volatile;

   package Reverb_Pck is new Tresses.FX.Reverb;

   TM : Tresses.Macro.Instance;
   Reverb : Reverb_Pck.Instance;
   Last_On : MIDI.MIDI_Key := 0;

   Buffer_A, Buffer_B : Tresses.Mono_Buffer
     (Noise_Nugget_SDK.Audio.Stereo_Buffer'Range);

   function MIDI_Param (Val : MIDI.MIDI_Data) return Param_Range
   is (Param_Range (Val) *
       (Param_Range'Last / Param_Range (MIDI.MIDI_Data'Last)));

   -------------
   -- Note_On --
   -------------

   procedure Note_On (Key : MIDI.MIDI_Key; Velocity : MIDI.MIDI_Data) is
   begin
      TM.Set_Pitch (Tresses.MIDI_Pitch (Key));
      TM.Note_On (MIDI_Param (Velocity));
      Last_On := Key;
   end Note_On;

   --------------
   -- Note_Off --
   --------------

   procedure Note_Off (Key : MIDI.MIDI_Key) is
      use MIDI;
   begin
      if Last_On = Key then
         TM.Note_Off;
      end if;
   end Note_Off;

   -------------------------
   -- Handle_MIDI_Message --
   -------------------------

   procedure Handle_MIDI_Message (Msg : MIDI.Message) is
   begin
      case Msg.Kind is

         when MIDI.Note_On =>
            We_Got_MIDI_Input := True;
            Note_On (Msg.Key, Msg.Velocity);

         when MIDI.Note_Off =>
            Note_Off (Msg.Key);

         when MIDI.Continous_Controller =>
            case Msg.Controller is
               when 0 =>
                  TM.Set_Param (1, MIDI_Param (Msg.Controller_Value));
               when 1 =>
                  TM.Set_Param (2, MIDI_Param (Msg.Controller_Value));
               when 2 =>
                  TM.Set_Param (3, MIDI_Param (Msg.Controller_Value));
               when 3 =>
                  TM.Set_Param (4, MIDI_Param (Msg.Controller_Value));
               when others =>
                  null;
            end case;
         when others =>
            null;
      end case;
   end Handle_MIDI_Message;

   --------------
   -- Callback --
   --------------

   procedure Callback (Output : out Noise_Nugget_SDK.Audio.Stereo_Buffer) is

      procedure Process_MIDI_Input
      is new Noise_Nugget_SDK.MIDI.For_Each_Input_Message
        (Handle_MIDI_Message);

   begin

      process_MIDI_Input;

      TM.Render (Buffer_A, Buffer_B);

      Buffer_B := Buffer_A;

      Reverb_Pck.Process (Reverb, Buffer_A, Buffer_B);

      for Index in Output'Range loop
         Output (Index).L := Buffer_A (Index);
         Output (Index).R := Buffer_B (Index);
      end loop;
   end Callback;

   --------------------
   -- Got_MIDI_Input --
   --------------------

   function Got_MIDI_Input return Boolean
   is (We_Got_MIDI_Input);

begin
   TM.Set_Engine (Tresses.Voice_Saw_Swarm);
   TM.Set_Param (1, Param_Range'Last / 2);
   TM.Set_Param (2, Param_Range'Last / 2);
   TM.Set_Param (3, 0);
   TM.Set_Param (4, Param_Range'Last / 2);
end Synth;
