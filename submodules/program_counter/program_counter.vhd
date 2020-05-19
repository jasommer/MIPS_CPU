----------------------------------------------------------------------------------
--
--  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
--  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
--  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
--  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
--  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
--  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
--  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. 
--
-- Copyright (C) 2020 Jan Sommer
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
-- 
-- Project Name:   MIPS_CPU
-- Description:    
--
-- Dependencies:   N/A
--
-- Revision: 1.1
--
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Generic (
            counter_size  : NATURAL := 32);
    Port ( clk      : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           en       : in  STD_LOGIC;
           ld       : in  STD_LOGIC;
           data_in  : in  STD_LOGIC_VECTOR (counter_size-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (counter_size-1 downto 0));
end program_counter;

architecture Behavioral of program_counter is
    signal counter_reg : UNSIGNED (counter_size-1 downto 0) := (others => '0');
begin
    
    data_out <= STD_LOGIC_VECTOR(counter_reg);
    
    counter_reg_behav: process(clk) begin
    
        if rising_edge(clk) then
            
            if(rst = '1') then -- sync reset
                
                counter_reg <= (others => '0');
                
            elsif(en = '1') then
                
                if(ld = '1') then
                    counter_reg <= UNSIGNED(data_in);
                else
                    counter_reg <= counter_reg + 4;
                end if;
                
            end if;
            
        end if;
    
    end process counter_reg_behav;
    
end Behavioral;
