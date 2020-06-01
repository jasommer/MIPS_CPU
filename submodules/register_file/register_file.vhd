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
--
--
-- Dependencies:   N/A
--
-- Revision: 1.0
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.log2;
use IEEE.MATH_REAL.ceil;

entity register_file is
    Generic (
            WORD_SIZE  : natural := 32;
            REG_COUNT  : natural := 32
    );
    Port ( 
           clk     : in  std_logic;
           wr_enab : in  std_logic;
           ra_addr : in  std_logic_vector (integer(ceil(log2(real(REG_COUNT))))-1 downto 0);
           rb_addr : in  std_logic_vector (integer(ceil(log2(real(REG_COUNT))))-1  downto 0);
           rc_addr : in  std_logic_vector (integer(ceil(log2(real(REG_COUNT))))-1  downto 0);
           rc_data : in  std_logic_vector (WORD_SIZE-1  downto 0);
           ra_data : out std_logic_vector (WORD_SIZE-1  downto 0);
           rb_data : out std_logic_vector (WORD_SIZE-1  downto 0)
           );
end register_file;

architecture Behavioral of register_file is

    type reg_array_type is array(0 to REG_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);
    signal reg_array : reg_array_type;
    
begin
    
    -- async read behav
    ra_data <= reg_array(to_integer(unsigned(ra_addr)));
    rb_data <= reg_array(to_integer(unsigned(rb_addr)));
    
    WRITE_BEHAV: process(clk)
    begin
        if rising_edge(clk) then
            if wr_enab = '1' then
                reg_array(to_integer(unsigned(rc_addr))) <= rc_data;
            end if;
        end if;
    end process WRITE_BEHAV;

end Behavioral;
