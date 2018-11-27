----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/03/2018 04:49:20 PM
-- Design Name: dflipflop.vhd
-- Module Name: dflipflop - dflipflop_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2 
-- Description: logic for a D-flip-flop
-- Component of btn_debounce.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dflipflop is
    port(
        clk         : in    std_logic;
        reset       : in    std_logic;
        D           : in    std_logic;
        Q           : out   std_logic;
        Qn          : out   std_logic    
    );
end entity dflipflop;

architecture dflipflop_arch of dflipflop is

begin
    
    DFF : process(clk, reset)
        begin 
            if(reset = '0') then 
                Q <= '0';
                Qn <= '1';
            elsif(rising_edge(clk)) then
                Q <= D;
                Qn <= not D;        
            end if;        
    end process;

end dflipflop_arch;
