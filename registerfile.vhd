library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registerfile is
    Port ( clk_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           write_enable_in : in STD_LOGIC;
           rM_data_out : out STD_LOGIC_VECTOR (15 downto 0);
           rN_data_out : out STD_LOGIC_VECTOR (15 downto 0);
           rD_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           sel_rM_in : in STD_LOGIC_VECTOR (2 downto 0);
           sel_rN_in : in STD_LOGIC_VECTOR (2 downto 0);
           sel_rD_in : in STD_LOGIC_VECTOR (2 downto 0));
end registerfile;

architecture Behavioral of registerfile is -- 8 Registers, 16 bits each
    type reg_array is array(0 to 7) of STD_LOGIC_VECTOR (15 downto 0);
    signal reg_file: reg_array := (others => x"0000"); -- assign all 0
    
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) and enable_in='1' then -- Data written out or to registers
            rM_data_out <= reg_file(to_integer(unsigned(sel_rM_in)));
            rN_data_out <= reg_file(to_integer(unsigned(sel_rN_in)));
            
            if write_enable_in ='1' then
                reg_file(to_integer(unsigned(sel_rD_in))) <= rD_data_in;
            end if;
        end if;
    end process;

end Behavioral;
