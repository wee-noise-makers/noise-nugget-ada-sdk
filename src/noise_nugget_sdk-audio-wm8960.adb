with HAL; use HAL;

with RP.Device;
with RP.GPIO; use RP.GPIO;
with RP.I2C; use RP.I2C;

package body Noise_Nugget_SDK.Audio.WM8960 is

   I2C1_SDA    : RP.GPIO.GPIO_Point := (Pin => 6);
   I2C1_SCL    : RP.GPIO.GPIO_Point := (Pin => 7);
   I2C1        : RP.I2C.I2C_Port renames RP.Device.I2C_1;
   WN8690_Addr : constant HAL.UInt7 := 16#1A#;

   --  The WM8960 is read-only, it's not possible to read the registers from
   --  the I2C interface. We therefore keep a local copy of the registers that
   --  we update when writing to the device.
   Register_Local_Copy : array (HAL.UInt7 range 0 .. 55) of HAL.UInt9 :=
     (16#097#, -- R0 (0x00)
      16#097#, -- R1 (0x01)
      16#000#, -- R2 (0x02)
      16#000#, -- R3 (0x03)
      16#000#, -- R4 (0x04)
      16#008#, -- F5 (0x05)
      16#000#, -- R6 (0x06)
      16#00A#, -- R7 (0x07)
      16#1C0#, -- R8 (0x08)
      16#000#, -- R9 (0x09)
      16#0FF#, -- R10 (0x0a)
      16#0FF#, -- R11 (0x0b)
      16#000#, -- R12 (0x0C) RESERVED
      16#000#, -- R13 (0x0D) RESERVED
      16#000#, -- R14 (0x0E) RESERVED
      16#000#, -- R15 (0x0F) RESERVED
      16#000#, -- R16 (0x10)
      16#07B#, -- R17 (0x11)
      16#100#, -- R18 (0x12)
      16#032#, -- R19 (0x13)
      16#000#, -- R20 (0x14)
      16#0C3#, -- R21 (0x15)
      16#0C3#, -- R22 (0x16)
      16#1C0#, -- R23 (0x17)
      16#000#, -- R24 (0x18)
      16#000#, -- R25 (0x19)
      16#000#, -- R26 (0x1A)
      16#000#, -- R27 (0x1B)
      16#000#, -- R28 (0x1C)
      16#000#, -- R29 (0x1D)
      16#000#, -- R30 (0x1E) RESERVED
      16#000#, -- R31 (0x1F) RESERVED
      16#100#, -- R32 (0x20)
      16#100#, -- R33 (0x21)
      16#050#, -- R34 (0x22)
      16#000#, -- R35 (0x23) RESERVED
      16#000#, -- R36 (0x24) RESERVED
      16#050#, -- R37 (0x25)
      16#000#, -- R38 (0x26)
      16#000#, -- R39 (0x27)
      16#000#, -- R40 (0x28)
      16#000#, -- R41 (0x29)
      16#040#, -- R42 (0x2A)
      16#000#, -- R43 (0x2B)
      16#000#, -- R44 (0x2C)
      16#050#, -- R45 (0x2D)
      16#050#, -- R46 (0x2E)
      16#000#, -- R47 (0x2F)
      16#002#, -- R48 (0x30)
      16#037#, -- R49 (0x31)
      16#000#, -- R50 (0x32) RESERVED
      16#080#, -- R51 (0x33)
      16#008#, -- R52 (0x34)
      16#031#, -- R53 (0x35)
      16#026#, -- R54 (0x36)
      16#0e9# -- R55 (0x37)
     );

   generic
      type Output_Type is mod <>;
      Min        : Output_Type;
      Max        : Output_Type;
      Mute_Value : Output_Type;
   function Gen_Volume_To_UInt (V : Audio_Volume) return Output_Type;

   --------------------
   -- Write_Register --
   --------------------

   function Write_Register (Reg : HAL.UInt7; Val : HAL.UInt9)
                            return Boolean
   is
      Status : RP.I2C.I2C_Status;

      --  WM8960 has 9-bit registers.
      --  I2C message is 2 bytes:
      --   1st: 7-bit register address + 1-bit data
      --   2nd: 8-bit remaining data

      B1 : constant UInt8 :=
        Shift_Left (UInt8 (Reg), 1) or
        UInt8 (Shift_Right (UInt16 (Val), 8) and 1);

      B2 : constant UInt8 := UInt8 (Val and 16#FF#);
   begin
      I2C1.Start_Write (Length => 2, Stop => True);

      I2C1.Write (B1, Status);
      if Status /= Ok then
         return False;
      end if;

      I2C1.Write (B2, Status);

      if Status /= Ok then
         raise Program_Error;
         return False;
      else
         Register_Local_Copy (Reg) := Val;
         return True;
      end if;
   end Write_Register;

   ------------------------
   -- Write_Register_Bit --
   ------------------------

   function Write_Register_Bit (Reg : HAL.UInt7;
                                Pos : HAL.UInt4;
                                Value : HAL.Bit)
                                return Boolean
   is
      Current : UInt9 := Register_Local_Copy (Reg);

      Mask : constant UInt9 := UInt9 (1) * 2**Natural (Pos);
   begin
      if Value = 1 then
         Current := Current or Mask;
      else
         Current := Current and (not Mask);
      end if;

      return Write_Register (Reg, Current);
   end Write_Register_Bit;

   ------------------------
   -- Gen_Volume_To_UInt --
   ------------------------

   function Gen_Volume_To_UInt (V : Audio_Volume) return Output_Type is
   begin
      if V = 0.0 then
         return Mute_Value;
      else
         declare
            Amplitude : constant Output_Type := Max - Min;

            Val : constant Output_Type :=
              Output_Type (Float (V) * Float (Amplitude));
         begin
            return Min + Val;
         end;
      end if;
   end Gen_Volume_To_UInt;

   -------------------
   -- Set_HP_Volume --
   -------------------

   procedure Set_HP_Volume (Left, Right : HAL.UInt7) is
      Unused : Boolean;

      L : constant UInt9 := 2#0_1_0000000# or UInt9 (Left);
      R : constant UInt9 := 2#0_1_0000000# or UInt9 (Right);
   begin
      Unused := Write_Register (REG_LOUT1_VOLUME, L);
      Unused := Write_Register (REG_ROUT1_VOLUME, R);

      Unused := Write_Register_Bit (REG_LOUT1_VOLUME, 8, 1);
      Unused := Write_Register_Bit (REG_ROUT1_VOLUME, 8, 1);
   end Set_HP_Volume;

   -------------------
   -- Set_HP_Volume --
   -------------------

   procedure Set_HP_Volume (L, R : Audio_Volume) is
      function To_UInt7 is new Gen_Volume_To_UInt (Output_Type => HAL.UInt7,
                                                   Min        => 2#0110000#,
                                                   Max        => 2#1111111#,
                                                   Mute_Value => 2#0101111#);
   begin
      Set_HP_Volume (To_UInt7 (L), To_UInt7 (R));
   end Set_HP_Volume;

   --------------------
   -- Set_DAC_Volume --
   --------------------

   procedure Set_DAC_Volume (Left, Right : HAL.UInt8) is
      Unused : Boolean;

      L : constant UInt9 := 2#0_00000000# or UInt9 (Left);
      R : constant UInt9 := 2#0_00000000# or UInt9 (Right);
   begin
      Unused := Write_Register (REG_LEFT_DAC_VOLUME, L);
      Unused := Write_Register (REG_RIGHT_DAC_VOLUME, R);

      Unused := Write_Register_Bit (REG_LEFT_DAC_VOLUME, 8, 1);
      Unused := Write_Register_Bit (REG_RIGHT_DAC_VOLUME, 8, 1);
   end Set_DAC_Volume;

   ----------------
   -- Initialize --
   ----------------

   function Initialize return Boolean is
      Controller_Config : constant I2C_Config :=
        (Role   => Controller,
         Timing => Standard_Mode);

      Success : Boolean;

   begin

      -- I2C --
      I2C1_SDA.Configure (Output, Pull_Up, RP.GPIO.I2C);
      I2C1_SCL.Configure (Output, Pull_Up, RP.GPIO.I2C);
      I2C1.Configure (Controller_Config);
      I2C1.Set_Address (WN8690_Addr);
      I2C1.Enable;

      --  Reset all registers
      Success := Write_Register (REG_RESET, 0);

      --  Enable Vref
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_1, 6, 1);

      --  Enable VMID
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_1, 7, 1);
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_1, 8, 1);

      --  Enable Left DAC
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_2, 8, 1);

      --  Enable Right DAC
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_2, 7, 1);

      --  Enable Left Output buffer
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_2, 6, 1);

      --  Enable Right Output buffer
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_2, 5, 1);

      --  Disable DAC Mute
      Success := Success and then
        Write_Register_Bit (REG_ADC_DAC_CTRL_1, 3, 0);

      --  Enable Left DAC to Out mix
      Success := Success and then
        Write_Register_Bit (REG_LEFT_OUT_MIX_1, 8, 1);

      --  Enable Righ DAC to Out mix
      Success := Success and then
        Write_Register_Bit (REG_RIGHT_OUT_MIX_2, 8, 1);

      --  Enable Left Out mix
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_3, 3, 1);

      --  Enable Righ Out mix
      Success := Success and then Write_Register_Bit (REG_PWR_MGMT_3, 2, 1);

      --  ADC CLK = SYSCLK / 256, DAC CLK = SYSCLK / 256, SYSCLK = MCLK
      Success := Success and then
        Write_Register (REG_CLOCKING_1, 2#000_000_00_0#);

      --  16-bit audio format
      Success := Success and then
        Write_Register_Bit (REG_AUDIO_INTERFACE_1, 3, 0);

      Set_DAC_Volume (2#11111111#, 2#11111111#);
      Set_HP_Volume (2#1011111#, 2#1011111#);

      return Success;
   end Initialize;

end Noise_Nugget_SDK.Audio.WM8960;
