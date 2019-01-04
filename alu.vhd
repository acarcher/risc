library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( clk_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           rM_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           rN_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           imm_data_in : in STD_LOGIC_VECTOR (7 downto 0);
           result_out : out STD_LOGIC_VECTOR (15 downto 0);
           branch_out : out STD_LOGIC;
           rD_write_enable_in : in STD_LOGIC;
           rD_write_enable_out : out STD_LOGIC);
end alu;

-- TODO: handle overflow correctly, add more than EQ to branching
architecture Behavioral of alu is
    signal signed_add : STD_LOGIC_VECTOR (15 downto 0);
    signal signed_sub : STD_LOGIC_VECTOR (15 downto 0);
    signal bothpos : STD_LOGIC;
    signal bothneg : STD_LOGIC;
    signal overflow : STD_LOGIC;
     
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) and enable_in='1' then
        
            rD_write_enable_out <= rD_write_enable_in;
            
            signed_sub <= STD_LOGIC_VECTOR(signed(rM_data_in) - signed(rN_data_in));
            signed_add <= STD_LOGIC_VECTOR(signed(rM_data_in) + signed(rN_data_in));
            
            -- Positive overflow chance
            if rM_data_in(rM_data_in'left) = '0' and rN_data_in(rN_data_in'left) = '0' then
                bothpos <= '1';
            else
                bothpos <= '0';
            end if;
            -- Negative overflow chance
            if rM_data_in(rM_data_in'left) = '1' and rN_data_in(rN_data_in'left) = '1' then
                bothneg <= '1';
            else
                bothneg <= '0';
            end if;
            -- check for overflow
            if (signed(signed_add) < 0 and bothpos = '1') or (signed(signed_add) > 0 and bothneg = '1') then
                overflow <= '1';
            else
                overflow <= '0';
            end if;
            
            case alu_op_in(3 downto 0) is -- 3-0 is opcode, alu_on_in(4) is condition bit
            
                when "0000" => -- ADD c bit: signed or unsigned RRR 1 = signed, 0 = unsigned
                    if alu_op_in(4) = '1' then
                        if overflow = '1' then
                            result_out <= signed_add;
                            -- do something to indicate overflow
                        else
                            result_out <= signed_add;
                        end if;    
                    else
                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) + unsigned(rN_data_in));
                        -- unsigned overflow possible
                    end if;
                    
                    branch_out <= '0';
                    
                when "0001" => -- SUB c bit: signed or unsigned RRR 1 = signed, 0 = unsigned
                    if alu_op_in(4) = '1' then
                        if overflow = '1' then
                            result_out <= signed_sub;
                            -- do something to indicate overflow
                        else
                            result_out <= signed_sub;
                        end if;
                    else
                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) - unsigned(rN_data_in));
                        -- unsigned overflow possible
                    end if;
                    
                    branch_out <= '0';
                    
                when "0010" => -- NOT RRU
                    result_out <= not rM_data_in;
                    branch_out <= '0';
                    
                when "0011" => -- AND RRR
                    result_out <= rM_data_in and rN_data_in;
                    branch_out <= '0';
                    
                when "0100" => -- OR RRR
                    result_out <= rM_data_in or rN_data_in;
                    branch_out <= '0';
                    
                when "0101" => -- XOR RRR
                    result_out <= rM_data_in xor rN_data_in;
                    branch_out <= '0';
                    
                when "0110" => -- LSL RRI(5)
                    result_out <= STD_LOGIC_VECTOR(shift_left(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
                    branch_out <= '0';
                    
                when "0111" => -- LSR RRI(5)
                    result_out <= STD_LOGIC_VECTOR(shift_right(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
                    branch_out <= '0';
                    
                when "1000" => -- CMP c bit: 1 for signed or 0 for unsigned RRR .. CPSR similar                    
                    -- Neg
                    if alu_op_in(4) = '1' and signed(signed_sub) < 0 then
                        result_out(15) <= '1';
                    else
                        result_out(15) <= '0';
                    end if;
                    -- Zer
                    if unsigned(rM_data_in) - unsigned(rN_data_in) = 0 then
                        result_out(14) <= '1';
                    else 
                        result_out(14) <= '0';
                    end if;
                    -- Car (unsigned underflow)
                    if alu_op_in(4) = '0' and unsigned(rM_data_in) - unsigned(rN_data_in) > unsigned(rM_data_in) + unsigned(rN_data_in) then
                        result_out(13) <= '1';
                    else
                        result_out(13) <= '0';
                    end if;
                    -- Ver (signed overflow)
                    if alu_op_in(4) = '1' and overflow ='1' then
                        result_out(12) <= '1';
                    else
                        result_out(12) <= '0';
                    end if;
                    
                    result_out(11 downto 0) <= x"000";
                    
                    
                    branch_out <= '0';
                    
                when "1001" => -- B UI(8) c bit: load from register or immediate; 1 = immediate, 0 = register .. immediate can address 256 locations
                    if alu_op_in(4) = '1' then
                        result_out <= x"00" & imm_data_in;
                    else
                        result_out <= rM_data_in;
                    end if;
                    branch_out <= '1';
                    
                when "1010" => -- BEQ only for now URR? (U, BRANCH LOC, OUTPUT FROM prev CMP)
                    if rN_data_in(14) = '1' then
                        result_out <= rM_data_in;
                        branch_out <= '1';
                    else
                        branch_out <= '0';
                    end if;
                    
                when "1011" => -- Imm c bit: high or low RI(8) 1 = high, 0 = low
                    if alu_op_in(4) = '1' then
                        result_out <= imm_data_in & x"00";
                    else
                        result_out <= x"00" & imm_data_in;
                    end if;
                    
                    branch_out <= '0';
                    
                when "1100" => -- LD c bit: ? RRU (DESTINATION REGISTER, SOURCE ADDRESS, U) .. how is rD chosen .. rM contains address to access
                    result_out <= rM_data_in;
                    branch_out <= '0';
                    
                when "1101" => -- ST cbit: ? URR (U, DESTINATION ADDRESS, DATA) .. data to store contained in rN but doesn't need to be used in ALU
                    result_out <= rM_data_in;
                    branch_out <= '0';
                    
                when others =>
                    NULL;
            end case;
        end if;                                           
    end process;


end Behavioral;
