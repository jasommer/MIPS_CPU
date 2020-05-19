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
use ieee.numeric_std.all;

entity tb_program_counter is
end tb_program_counter;

architecture tb of tb_program_counter is

    component program_counter
        port (clk      : in std_logic;
              rst      : in std_logic;
              en       : in std_logic;
              ld       : in std_logic;
              data_in  : in std_logic_vector (31 downto 0);
              data_out : out std_logic_vector (31 downto 0));
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal en       : std_logic;
    signal ld       : std_logic;
    signal data_in  : std_logic_vector (31 downto 0);
    signal data_out : std_logic_vector (31 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0'; 
    signal TbSimEnded : std_logic := '0';

begin

    dut : program_counter
    port map (clk      => clk,
              rst      => rst,
              en       => en,
              ld       => ld,
              data_in  => data_in,
              data_out => data_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;
    
    stimuli : process
    begin
        -- init signals
        en <= '0';
        ld <= '0';
        data_in <= (others => '0');

        rst <= '1';
        
        wait for (TbPeriod/2)*3;
        assert (unsigned(data_out) = 0) report "reset not applied correctly!";
        assert not(unsigned(data_out) = 0) report "reset applied correctly" severity note;
        rst <= '0';
        en <= '1';
        data_in <= x"00000020";
        
        wait for TbPeriod*3;
        assert (unsigned(data_out) = 12) report "increment not applied correctly!";
        assert not(unsigned(data_out) = 12) report "increment applied correctly" severity note;
        ld <= '1';
        
        wait for TbPeriod;
        assert (unsigned(data_out) = x"00000020") report "load not applied correctly!";
        assert not(unsigned(data_out) = x"00000020") report "load applied correctly" severity note;
        ld <= '0';
        
        wait for TbPeriod;
        assert (unsigned(data_out) = x"00000024") report "increment after load not applied correctly!";
        assert not(unsigned(data_out) = x"00000024") report "increment after load applied correctly" severity note;
        rst <= '1';
        
        wait for TbPeriod;
        assert (unsigned(data_out) = 0) report "reset not applied correctly!";
        assert not(unsigned(data_out) = 0) report "reset applied correctly" severity note;
        
         -- Stop the clock and terminate the simulation
        TbSimEnded <= '1';
        std.env.finish;
        wait;
    end process;

end tb;