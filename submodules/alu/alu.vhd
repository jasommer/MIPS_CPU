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
-- Revision: 1.0
--
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Generic (
        WORD_SIZE  : natural := 32
    );
    Port ( 
        opcode : in  std_logic_vector (3 downto 0);
        data_a : in  std_logic_vector (WORD_SIZE-1 downto 0);
        data_b : in  std_logic_vector (WORD_SIZE-1 downto 0);
        flags  : out std_logic_vector (3 downto 0);
        result : out std_logic_vector (WORD_SIZE-1 downto 0)
    );
end alu;

architecture Behavioral of alu is

    signal opA_signed_ext  : signed (WORD_SIZE downto 0) := (others => '0');
    signal opB_signed_ext  : signed (WORD_SIZE downto 0) := (others => '0');
    signal res_signed_ext  : signed (WORD_SIZE downto 0) := (others => '0');
    signal result_internal : std_logic_vector (WORD_SIZE-1 downto 0) := (others => '0');
        
begin
    
    -- extend operands by one bit (for overflow detection)
    opA_signed_ext <= resize(signed(data_a), opA_signed_ext'length);
    opB_signed_ext <= resize(signed(data_b), opB_signed_ext'length);
    -- resize the result to original width (unsigned resize operation so that overflows behave as expected)
	result_internal <= std_logic_vector(resize(unsigned(res_signed_ext), result_internal'length)); 
	result <= result_internal;
	
	-- flag assignments --
	-- overflow flag
	flags(0) <= res_signed_ext(res_signed_ext'LEFT) xor result_internal(result_internal'LEFT);
    
    RESULT_MUX_BEHAV: process(opcode, opA_signed_ext, opB_signed_ext)
    begin
        case opcode is
            when x"0" => -- AND
                res_signed_ext <= opA_signed_ext AND opB_signed_ext;
                
            when x"1" => -- OR
                res_signed_ext <= opA_signed_ext OR opB_signed_ext;
                
            when x"2" => -- ADD
                res_signed_ext <= opA_signed_ext + opB_signed_ext;
                
            when x"3" => -- LUI
                res_signed_ext(31 downto 16) <= opB_signed_ext(15 downto 0);
                res_signed_ext(15 downto 0)  <= x"0000";
                res_signed_ext(32)           <= '0';
                
            when x"4" => -- XOR
                res_signed_ext <= opA_signed_ext XOR opB_signed_ext;
                
            when x"5" => -- SUB
                res_signed_ext <= opA_signed_ext - opB_signed_ext;
                
            when x"6" => -- SLT
                if (opA_signed_ext < opB_signed_ext) then
                    res_signed_ext <= b"0" & x"00000001";
                else
                    res_signed_ext <= (others => '0');
                end if;
            
            when x"7" => -- NOR
                res_signed_ext <= opA_signed_ext NOR opB_signed_ext;        
            
            when others =>
                report "undefined ALU opcode" severity warning;
                res_signed_ext <= (others => '0');
                
        end case;
        
    end process RESULT_MUX_BEHAV;
    
            
end Behavioral;
