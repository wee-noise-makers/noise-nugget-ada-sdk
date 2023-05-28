with Noise_Nugget_SDK.Audio;
with MIDI;

package Synth is

   procedure Note_On (Key : MIDI.MIDI_Key; Velocity : MIDI.MIDI_Data);
   procedure Note_Off (Key : MIDI.MIDI_Key);

   procedure Callback (Output : out Noise_Nugget_SDK.Audio.Stereo_Buffer);


   function Got_MIDI_Input return Boolean;

end Synth;
