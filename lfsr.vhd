----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/03/2018 01:44:35 PM
-- Design Name: lfsr.vhd
-- Module Name: lfsr - lfsr_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: 
-- 16 bit Fibonacci configuration
-- Linear Feedback Shift Register 
-- for pseudo random number generation
-- When enable condition is asserted 
-- A one is added to the top 8 bits of the LFSR
-- And a one is added to the bottom 8 bits of the LFSR
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity lfsr is
    port(
        clk         : in    std_logic;
        reset       : in    std_logic;
        en          : in    std_logic;
        delay       : in    std_logic;
        reg_in      : in    std_logic_vector(15 downto 0);
        en_out      : out   std_logic;
        lfsr_out    : out   std_logic_vector(15 downto 0)
    );
end entity lfsr;

architecture lfsr_arch of lfsr is


--SIGNALS    
    signal shift    	: unsigned(15 downto 0)    := unsigned(reg_in);
    signal xor_out      : std_logic;
    signal random_flag  : std_logic;        --Flag to signal the UART interface that a strike has occured

        
begin

          
    LINEAR_FEEDBACK_SHIFT_REGISTER  :   process(clk, reset, en, delay, reg_in)
        begin
            if(reset = '1') then
                shift <= unsigned(reg_in);
            elsif(rising_edge(clk)) then                
                if(delay = '1') then
                    en_out <= random_flag;
                    shift(15) <= (((shift(0) xor shift(2)) xor shift(3)) xor shift(5));     --LFSR taps
                    shift(14 downto 0) <= shift(15 downto 1);                               --LFSR shift
                    random_flag <= '0';
                elsif(en = '1') then                        --When enable condition is true LFSR output is modified
                    random_flag <= '1';
                    shift(7 downto 0) <= (shift(7 downto 0) + 1);       --A one is added to the lower 8 bits of the LFSR
                    shift(15 downto 8) <= (shift(15 downto 8) + 1);     --A one is added to the upper 8 bits of the LFSR
                end if;
            end if;
    end process;
           
              
    lfsr_out <= std_logic_vector(shift);


end lfsr_arch;
