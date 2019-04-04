----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 10/28/2018 07:17:23 PM
-- Design Name: clock_divider.vhd
-- Module Name: clock_divider - clock_divider_arch
-- Project Name: capstone-fpga-memory-model
-- Target Devices: XC7A35TICSG324-1L
-- Tool Versions: Vivado 2018.2
-- Description: 
-- 4 option clock divider using counters
-- Controled by SW(1 downto 0):
-- 00 = 2Hz
-- 01 = 5Hz
-- 10 = 10Hz
-- 11 = 100Hz
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity clock_divider is
    port(
        clk_in          : in    std_logic;
        reset           : in    std_logic;
        sel             : in    std_logic_vector(1 downto 0);
        clk_out         : out   std_logic
    );
end entity clock_divider;

architecture clock_divider_arch of clock_divider is

--SIGNALS    
    signal count        : integer;
    signal clk          : std_logic;
    
begin

    process(clk_in, reset)
        begin
            if(reset = '1') then
                count <= 0;
                clk     <= '0';
            elsif(rising_edge(clk_in)) then
                --2Hz clock
                --period = 0.5sec
                --counts = 49,999,999
                if(sel = "00") then
                    if(count = 49999999) then
                        count <= 0;
                        clk     <= not clk;
                    else
                        count <= count + 1;
                    end if;
                    
                --5Hz clock
                --period = 0.2sec
                --counts = 19,999,999
                elsif(sel = "01") then
                    if(count = 19999999) then
                        count <= 0;
                        clk     <= not clk;
                    else
                        count <= count + 1;
                    end if;
                    
                --10Hz clock
                --period = 0.1sec
                --counts = 10,000,000
                elsif(sel = "10") then
                    if(count = 9999999) then
                        count <= 0;
                        clk     <= not clk;
                    else
                        count <= count + 1;
                    end if;
                    
                --100Hz clock
                --period = 0.01sec
                --counts = 100,000
                elsif(sel = "11") then
                    if(count = 999999) then
                        count <= 0;
                        clk     <= not clk;
                    else
                        count <= count + 1;
                    end if;
                end if;
            end if;
    end process;
    
    clk_out <= clk;
    
end clock_divider_arch;
