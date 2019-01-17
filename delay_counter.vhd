----------------------------------------------------------------------------------
-- Stefan Andersson 
-- 
-- Create Date: 11/03/2018 02:24:39 PM
-- Design Name: delay_counter.vhd
-- Module Name: delay_counter - delay_counter_arch
-- Project Name: capstone-fpga-memory-model
-- Target Devices: XC7A35TICSG324-1L
-- Tool Versions: Vivado 2018.2
-- Description: 0.5 second delay counter used for updating the LFSR
-- Component of lfsr.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delay_counter is
    port(
        clock           : in    std_logic;
        reset           : in    std_logic;
        delay_out       : out   std_logic
    );
end entity delay_counter;

architecture delay_counter_arch of delay_counter is
    
    signal cnt_int      : integer;
    signal delay_int    : integer   := 200000000;
    
begin
    
    ONE_SEC_DELAY : process(clock, reset)
        begin
            if(reset = '1') then
                cnt_int <= 0;
            elsif(rising_edge(clock)) then
                if(cnt_int = (delay_int - 1)) then
                    cnt_int <= 0;
                    delay_out <= '1';
                else
                    cnt_int <= cnt_int + 1;
                    delay_out <= '0';
                end if;
            end if;
        end process;

end delay_counter_arch;
