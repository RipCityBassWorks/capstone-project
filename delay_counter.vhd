----------------------------------------------------------------------------------
-- Stefan Andersson 
-- 
-- Create Date: 11/03/2018 02:24:39 PM
-- Design Name: delay_counter.vhd
-- Module Name: delay_counter - delay_counter_arch
-- Project Name: capstone-fpga-memory-model
-- Target Devices: XC7A35TICSG324-1L
-- Tool Versions: Vivado 2018.2
-- Description: 30 second delay counter used 
-- for sending the data stream to the UART
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delay_counter is
    port(
        clk             : in    std_logic;
        reset           : in    std_logic;
        delay_out       : out   std_logic
    );
end entity delay_counter;

architecture delay_counter_arch of delay_counter is

--SIGNALS    
    signal cnt          : unsigned(31 downto 0);
    signal cnt_max      : unsigned(31 downto 0)     := "10110010110100000101111000000000"; --30s delay
    
    
begin
    
    
    DELAY_COUNT :   process(clk, reset)
        begin
            if(reset = '1') then
                cnt <= X"00000000";
            elsif(rising_edge(clk)) then
                if(cnt = cnt_max) then
                    cnt <= X"00000000";
                    delay_out <= '1';
                else
                    cnt <= cnt + 1;
                    delay_out <= '0';
                end if;
            end if;
        end process;

end delay_counter_arch;
