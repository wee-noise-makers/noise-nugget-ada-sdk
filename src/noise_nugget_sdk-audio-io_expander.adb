with Noise_Nugget_SDK.I2C; use Noise_Nugget_SDK.I2C;

with HAL.I2C;

package body Noise_Nugget_SDK.Audio.IO_Expander is

   TCA6408_Addr : constant := 16#20#;

   --  Input_Reg_Addr  : constant := 0;
   Output_Reg_Addr : constant := 1;
   --  Invert_Reg_Addr : constant := 2;
   Config_Reg_Addr : constant := 3;

   Config_Reg_Init : constant HAL.UInt8 := 2#00100000#;
   --  1 for input, 0 for output
   --
   --  Speaker Enable L : out
   --  Speaker Enable R : out
   --  Speaker Gain 0   : out
   --  Speaker Gain 1   : out
   --  DAC not Reset    : out
   --  Jack Detect      : in
   --  Test Point 1     : out
   --  Test Point 2     : out

   SPK_Enable_L_Mask  : constant := 2#0000_0001#;
   SPK_Enable_R_Mask  : constant := 2#0000_0010#;
   SPK_Gain_0_Mask    : constant := 2#0000_0100#;
   SPK_Gain_1_Mask    : constant := 2#0000_1000#;
   DAC_Not_Reset_Mask : constant := 2#0001_0000#;

   Output_Reg_Init : constant HAL.UInt8 := 2#0000_0000#;
   Output_Reg_State : HAL.UInt8 := Output_Reg_Init;

   --------------------
   -- Write_Register --
   --------------------

   function Write_Register (Reg, Val : HAL.UInt8) return Boolean is
      use HAL.I2C;
      use HAL;

      Status : HAL.I2C.I2C_Status;

   begin

      Mem_Write
        (Addr => TCA6408_Addr * 2,
         Mem_Addr => HAL.UInt16 (Reg),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data =>  (1 => Val),
         Status => Status);

      return Status = HAL.I2C.Ok;
   end Write_Register;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not Write_Register (Output_Reg_Addr, Output_Reg_Init) then
         raise Program_Error;
      end if;

      if not Write_Register (Config_Reg_Addr, Config_Reg_Init) then
         raise Program_Error;
      end if;
   end Initialize;

   ------------------
   -- Enable_Codec --
   ------------------

   procedure Enable_Codec is
      use HAL;

      New_State : constant HAL.UInt8 :=
        Output_Reg_State or DAC_Not_Reset_Mask;
   begin
      if Write_Register (Output_Reg_Addr, New_State) then
         Output_Reg_State := New_State;
      else
         raise Program_Error;
      end if;
   end Enable_Codec;

   --------------------
   -- Enable_Speaker --
   --------------------

   procedure Enable_Speaker (L, R : Boolean := True) is
      use HAL;

      New_State : HAL.UInt8 := Output_Reg_State;
   begin
      if L then
         New_State := New_State or SPK_Enable_L_Mask;
      else
         New_State := New_State and (not SPK_Enable_L_Mask);
      end if;

      if R then
         New_State := New_State or SPK_Enable_R_Mask;
      else
         New_State := New_State and (not SPK_Enable_R_Mask);
      end if;

      if Write_Register (Output_Reg_Addr, New_State) then
         Output_Reg_State := New_State;
      else
         raise Program_Error;
      end if;
   end Enable_Speaker;

   ----------------------
   -- Set_Speaker_Gain --
   ----------------------

   procedure Set_Speaker_Gain (G0, G1 : Boolean) is
      use HAL;

      New_State : HAL.UInt8 := Output_Reg_State;
   begin

      if G0 then
         New_State := New_State or SPK_Gain_0_Mask;
      else
         New_State := New_State and (not SPK_Gain_0_Mask);
      end if;

      if G1 then
         New_State := New_State or SPK_Gain_1_Mask;
      else
         New_State := New_State and (not SPK_Gain_1_Mask);
      end if;

      if Write_Register (Output_Reg_Addr, New_State) then
         Output_Reg_State := New_State;
      else
         raise Program_Error;
      end if;
   end Set_Speaker_Gain;

begin
   Initialize;
end Noise_Nugget_SDK.Audio.IO_Expander;
