library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controlunit is
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           stage_out : out STD_LOGIC_VECTOR (5 downto 0));
end controlunit;

architecture Behavioral of controlunit is
    signal stage: STD_LOGIC_VECTOR(5 downto 0) := "000001";

begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_in = '1' then
                stage <= "000001";
            else
                case stage is
                    when "000001" => -- Fetch
                        stage <= "000010";
                    when "000010" => -- Decode
                        stage <= "000100";
                    when "000100" => -- Reg read
                        stage <= "001000";
                    when "001000" => -- Execute
                        if alu_op_in(3 downto 0) = "1100" or alu_op_in(3 downto 0) = "1101" then --LD or ST
                            stage <= "010000";
                        else
                            stage <= "100000";
                        end if;
                    when "010000" => -- Memory
                        stage <= "100000";
                    when "100000" => -- Reg write
                        stage <= "000001";
                    when others =>
                        stage <= "000001";
                end case;
            end if;
        end if;
    end process;

    stage_out <= stage;

end Behavioral;
