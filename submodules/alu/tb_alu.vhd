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

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end tb_alu;

architecture tb of tb_alu is
    
    component alu
        Generic (
            WORD_SIZE  : natural := 32
        );
        port (opcode : in std_logic_vector (3 downto 0);
              data_a : in std_logic_vector (word_size-1 downto 0);
              data_b : in std_logic_vector (word_size-1 downto 0);
              flags  : out std_logic_vector (3 downto 0);
              result : out std_logic_vector (word_size-1 downto 0));
    end component;
    
    signal WORD_SIZE  : natural := 32;
    signal opcode : std_logic_vector (3 downto 0);
    signal data_a : std_logic_vector (word_size-1 downto 0);
    signal data_b : std_logic_vector (word_size-1 downto 0);
    signal flags  : std_logic_vector (3 downto 0);
    signal result : std_logic_vector (word_size-1 downto 0);

    constant TbPeriod : time := 10 ns; 
    signal TbSimEnded : std_logic := '0';

begin

    dut : alu
    port map (opcode => opcode,
              data_a => data_a,
              data_b => data_b,
              flags  => flags,
              result => result);

    stimuli : process
    begin
        opcode <= x"0";
        data_a <= x"000A0003";
        data_b <= x"F0000002";
        wait for TbPeriod;
        assert (data_a AND data_b) /= result report "AND operation behaves as expected" severity note;
        assert (data_a AND data_b) = result report "AND operation failed!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"1";
        wait for TbPeriod;
        assert (data_a OR data_b) /= result report "OR operation behaves as expected" severity note;
        assert (data_a OR data_b) = result report "OR operation failed!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"2";
        data_a <= x"000A0003";
        data_b <= x"00000002";
        wait for TbPeriod;
        assert (signed(data_a) + signed(data_b)) /= signed(result) report "ADD operation behaves as expected" severity note;
        assert (signed(data_a) + signed(data_b)) = signed(result) report "ADD operation failed!" severity failure;
        assert flags(0) /= '0' report "overflow flag not set (as expected)" severity note;
        assert flags(0) = '0' report "overflow flag was set incorrectly!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"FFFFFF03";
        data_b <= x"FFFFFF02";
        wait for TbPeriod;
        assert (signed(data_a) + signed(data_b)) /= signed(result) report "ADD operation with negative operands behaves as expected" severity note;
        assert (signed(data_a) + signed(data_b)) = signed(result) report "ADD operation with negative operands failed!" severity failure;
        assert flags(0) /= '0' report "overflow flag not set (as expected)" severity note;
        assert flags(0) = '0' report "overflow flag was set incorrectly!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"7FFFFFFF";
        data_b <= x"7FFFFFFF";
        wait for TbPeriod;
        assert (signed(data_a) + signed(data_b)) /= signed(result) report "ADD operation overflow behaves as expected" severity note;
        assert (signed(data_a) + signed(data_b)) = signed(result) report "ADD operation overflow test failed!" severity failure;
        assert flags(0) /= '1' report "overflow flag set correctly" severity note;
        assert flags(0) = '1' report "overflow flag was not set correctly!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"3";
        data_a <= x"00000000";
        data_b <= x"DEADBEEF";
        wait for TbPeriod;
        assert x"BEEF0000" /= result report "LUI operation behaves as expected" severity note;
        assert x"BEEF0000" = result report "LUI operation failed!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"4";
        wait for TbPeriod;
        assert (signed(data_a) xor signed(data_b)) /= signed(result) report "XOR behaves as expected" severity note;
        assert (signed(data_a) xor signed(data_b)) = signed(result) report "XOR test failed!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"5";
        data_a <= x"000A0003";
        data_b <= x"00000002";
        wait for TbPeriod;
        assert (signed(data_a) - signed(data_b)) /= signed(result) report "SUB operation behaves as expected" severity note;
        assert (signed(data_a) - signed(data_b)) = signed(result) report "SUB operation failed!" severity failure;
        assert flags(0) /= '0' report "overflow flag not set (as expected)" severity note;
        assert flags(0) = '0' report "overflow flag was set incorrectly!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"FFFFFF03";
        data_b <= x"FFFFFF02";
        wait for TbPeriod;
        assert (signed(data_a) - signed(data_b)) /= signed(result) report "SUB operation with negative operands behaves as expected" severity note;
        assert (signed(data_a) - signed(data_b)) = signed(result) report "SUB operation with negative operands failed!" severity failure;
        assert flags(0) /= '0' report "overflow flag not set (as expected)" severity note;
        assert flags(0) = '0' report "overflow flag was set incorrectly!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"F0000000";
        data_b <= x"7FFFFFFF";
        wait for TbPeriod;
        assert (signed(data_a) - signed(data_b)) /= signed(result) report "SUB operation overflow behaves as expected" severity note;
        assert (signed(data_a) - signed(data_b)) = signed(result) report "SUB operation overflow test failed!" severity failure;
        assert flags(0) /= '1' report "overflow flag set correctly" severity note;
        assert flags(0) = '1' report "overflow flag was not set correctly!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"6";
        data_a <= x"000000FF";
        data_b <= x"000000EE";
        wait for TbPeriod;
        assert x"00000000" /= result report "SLT operation behaves as expected" severity note;
        assert x"00000000" = result report "SLT operation failed!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"FFFFFF3A";
        data_b <= x"FFFFFFDD";
        wait for TbPeriod;
        assert x"00000001" /= result report "SLT operation with negative operands behaves as expected" severity note;
        assert x"00000001" = result report "SLT operation with negative operands failed!" severity failure;
        
        wait for TbPeriod;
        data_a <= x"00ABCD00";
        data_b <= x"00ABCD00";
        wait for TbPeriod;
        assert x"00000000" /= result report "SLT operation with equal operands behaves as expected" severity note;
        assert x"00000000" = result report "SLT operation with equal operands failed!" severity failure;
        
        wait for TbPeriod;
        opcode <= x"7";
        data_b <= x"F0ABCD00";
        wait for TbPeriod;
        assert (signed(data_a) nor signed(data_b)) /= signed(result) report "NOR behaves as expected" severity note;
        assert (signed(data_a) nor signed(data_b)) = signed(result) report "NOR test failed!" severity failure;
        
        wait for TbPeriod;
        -- terminate simulation
        std.env.finish;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;