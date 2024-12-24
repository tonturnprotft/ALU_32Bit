library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_32bit is
    Port (
        A         : in  STD_LOGIC_VECTOR(31 downto 0); -- 32-bit input A
        B         : in  STD_LOGIC_VECTOR(31 downto 0); -- 32-bit input B
        A_invert  : in  STD_LOGIC;                    -- A invert control
        B_invert  : in  STD_LOGIC;                    -- B invert control
        Cin       : in  STD_LOGIC;                    -- Initial Carry-in
        Operation : in  STD_LOGIC_VECTOR(1 downto 0); -- Operation selector
        Result    : out STD_LOGIC_VECTOR(31 downto 0);-- 32-bit Result output
        Cout      : out STD_LOGIC;                    -- Carry-out
        Overflow  : out STD_LOGIC                     -- Overflow detection
    );
end ALU_32bit;

architecture Behavioral of ALU_32bit is
    signal Carry : STD_LOGIC_VECTOR(31 downto 0); -- Carry chain
    signal Final_Carry : STD_LOGIC;              -- Internal signal for final carry-out
    signal Set   : STD_LOGIC_VECTOR(31 downto 0); -- Set signals for SLT

    component ALU_1bit
        Port (
            a         : in  STD_LOGIC;
            b         : in  STD_LOGIC;
            Less      : in  STD_LOGIC;
            A_invert  : in  STD_LOGIC;
            B_invert  : in  STD_LOGIC;
            Cin       : in  STD_LOGIC;
            Operation : in  STD_LOGIC_VECTOR(1 downto 0);
            Result    : out STD_LOGIC;
            Cout      : out STD_LOGIC;
            Set       : out STD_LOGIC;
            Overflow  : out STD_LOGIC
        );
    end component;
begin
    -- Handle the LSB (bit 0)
    LSB: ALU_1bit
        port map (
            a         => A(0),
            b         => B(0),
            Less      => '0', -- No Less signal for the LSB
            A_invert  => A_invert,
            B_invert  => B_invert,
            Cin       => Cin,
            Operation => Operation,
            Result    => Result(0),
            Cout      => Carry(0),
            Set       => Set(0),
            Overflow  => Open
        );

    -- Handle bits 1 to 30 using a generate loop
    bits1to30: for i in 1 to 30 generate
        ibit: ALU_1bit
            port map (
                a         => A(i),
                b         => B(i),
                Less      => '0', -- No Less signal for intermediate bits
                A_invert  => A_invert,
                B_invert  => B_invert,
                Cin       => Carry(i - 1),
                Operation => Operation,
                Result    => Result(i),
                Cout      => Carry(i),
                Set       => Set(i),
                Overflow  => Open
            );
    end generate;

    -- Handle the MSB (bit 31)
    MSB: ALU_1bit
        port map (
            a         => A(31),
            b         => B(31),
            Less      => Set(31), -- SLT signal applied to the MSB
            A_invert  => A_invert,
            B_invert  => B_invert,
            Cin       => Carry(30),
            Operation => Operation,
            Result    => Result(31),
            Cout      => Final_Carry, -- Use an internal signal for carry-out
            Set       => Set(31),
            Overflow  => Open
        );

    -- Assign the internal carry-out signal to Cout
    Cout <= Final_Carry;

    -- Overflow detection in the MSB
    Overflow <= Carry(30) xor Final_Carry; -- Overflow occurs if carry into MSB ≠ carry out of MSB

end Behavioral;
