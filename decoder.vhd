library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port (  clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            instruction_in : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_out : out STD_LOGIC_VECTOR (4 downto 0);
            imm_data_out : out STD_LOGIC_VECTOR (7 downto 0); -- 16 or 8
            write_enable_out : out STD_LOGIC;
            sel_rM_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_out : out STD_LOGIC_VECTOR (2 downto 0));
end decoder;

architecture Behavioral of decoder is

begin
    process(clk_in)
    begin
        if rising_edge(clk_in) and enable_in='1' then
            -- defined in ISA
            -- first bit of alu_op_out is a condition bit
            alu_op_out <= instruction_in(15 downto 11);
            imm_data_out <= instruction_in(7 downto 0);
            sel_rM_out <= instruction_in(7 downto 5);
            sel_rN_out <= instruction_in(4 downto 2);
            sel_rD_out <= instruction_in(10 downto 8);
            
            case instruction_in(14 downto 11) is -- generate the write signal
                when "1001" => -- b
                    write_enable_out <= '0';
                when "1010" => -- beq
                    write_enable_out <= '0';
                when "1101" => -- st
                    write_enable_out <= '0';
                when others =>
                    write_enable_out <= '1'; 
            end case;
                
         end if;
     end process;

end Behavioral;
