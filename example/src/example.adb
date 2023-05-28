with RP.Multicore;
with CPU_Core_1;

procedure Example is
begin

   --  Start the second CPU core that will run the synth
   RP.Multicore.Launch_Core1 (Trap_Vector   => CPU_Core_1.Trap_Vector,
                              Stack_Pointer => CPU_Core_1.Stack_Pointer,
                              Entry_Point   => CPU_Core_1.Entry_Point);
   loop
      null;
   end loop;
end Example;
