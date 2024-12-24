library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_1bit is
    Port (
        a         : in  STD_LOGIC;                -- Input a
        b         : in  STD_LOGIC;                -- Input b
        Less      : in  STD_LOGIC;                -- Input Less for SLT
        A_invert  : in  STD_LOGIC;                -- A invert control
        B_invert  : in  STD_LOGIC;                -- B invert control
        Cin       : in  STD_LOGIC;                -- Carry-in
        Operation : in  STD_LOGIC_VECTOR(1 downto 0); -- Operation selector
        Result    : out STD_LOGIC;               -- Result output
        Cout      : out STD_LOGIC;               -- Carry-out
        Set       : out STD_LOGIC;               -- Set output for SLT
        Overflow  : out STD_LOGIC                -- Overflow detection
    );
end ALU_1bit;

architecture Behavioral of ALU_1bit is
    signal a_inverted : STD_LOGIC;
    signal b_inverted : STD_LOGIC;
    signal b_mux      : STD_LOGIC;
    signal sum        : STD_LOGIC;
begin

    -- Invert A if A_invert is '1'
    a_inverted <= not a when A_invert = '1' else a;

    -- Invert B if B_invert is '1'
    b_inverted <= not b when B_invert = '1' else b;

    -- Sum calculation (Adder logic)
    sum <= a_inverted xor b_inverted xor Cin;
    Cout <= (a_inverted and b_inverted) or (b_inverted and Cin) or (a_inverted and Cin);

    -- Overflow detection
	 Overflow <= ((a_inverted xor b_inverted) and not sum) or (a_inverted and b_inverted);


    -- Operation selection
    process(Operation, a_inverted, b_inverted, sum, Less)
    begin
        case Operation is
            when "00" => Result <= a_inverted and b_inverted; -- AND
            when "01" => Result <= a_inverted or b_inverted;  -- OR
            when "10" => Result <= sum;                      -- ADD/SUB
            when "11" => Result <= Less;                     -- SLT
            when others => Result <= '0';                    -- Default case
        end case;
    end process;

    -- Set output for SLT
    Set <= sum;

end Behavioral;
