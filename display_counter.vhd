----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 01/10/2019 11:14:40 PM
-- Design Name: display_coutner.vhd
-- Module Name: display_counter - display_counter_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: Handles the timing for the 7 segment display
-- Anode and cathode are both driven low when active
-- All digits should be driven once every 1 to 16ms
-- Refresh period is 10ms
-- 100Hz refresh rate
-- A digit is refreshed every 2.5ms
--
-- Componen of char_decoder.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity display_counter is
    port(
        clk             : in    std_logic;
        reset           : in    std_logic;
        seg_sel         : out   std_logic_vector(1 downto 0)
    );
end display_counter;

architecture display_counter_arch of display_counter is
    
    signal count        : integer;
    signal output       : std_logic_vector(1 downto 0);
    
begin

    process(clk, reset)
        begin
            if(reset = '1') then
                count <= 0;
            elsif(rising_edge(clk)) then
                if(count = 249999) then
                    output <= "00";       -- activate LED1 and Deactivate LED2, LED3, LED4
                    count <= count + 1;
                elsif(count = 499999) then
                    output <= "01";       -- activate LED2 and Deactivate LED1, LED3, LED4
                    count <= count + 1;
                elsif(count = 749999) then
                    output <= "10";       -- activate LED3 and Deactivate LED2, LED1, LED4
                    count <= count + 1;
                elsif(count = 999999) then
                    output <= "11";       -- activate LED4 and Deactivate LED2, LED3, LED1
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
    end process;
    
    seg_sel <= output;


end display_counter_arch;
