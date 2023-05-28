with HAL;

package CPU_Core_1 is

   function Trap_Vector return HAL.UInt32;
   function Stack_Pointer return HAL.UInt32;
   function Entry_Point return HAL.UInt32;

end CPU_Core_1;
