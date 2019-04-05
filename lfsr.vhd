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
--
-- An enable condition flips a bit determined 
-- by the current value of a 16 digit counter 
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity lfsr is
    port(
        clk         : in    std_logic;
        reset       : in    std_logic;
        en          : in    std_logic;
        reg_in      : in    std_logic_vector(15 downto 0);
        en_out      : out   std_logic;
        lfsr_out    : out   std_logic_vector(15 downto 0)
    );
end entity lfsr;

architecture lfsr_arch of lfsr is

--SIGNALS    
    signal shift    	: std_logic_vector(15 downto 0)  := reg_in;
    signal count        : integer;
    

begin
     
       
    --16 bit Fibonacci configuration LFSR
    --bit(15) = (((bit(0) XOR bit(2)) xor bit(3)) XOR bit(5))  
    --Right shift toward LSB 
    LINEAR_FEEDBACK_SHIFT_REGISTER  :   process(clk, reset, en, reg_in)
        begin
            if(reset = '1') then
                shift <= reg_in;
            elsif(rising_edge(clk)) then
                if(en = '1') then
                    shift(count) <= not shift(count);
                    en_out <= '1';
                    shift(15) <= (((shift(0) xor shift(2)) xor shift(3)) xor shift(5));
                    shift(14 downto 0) <= shift(15 downto 1);
                    lfsr_out <= shift;
                else
                    shift(15) <= (((shift(0) xor shift(2)) xor shift(3)) xor shift(5));
                    shift(14 downto 0) <= shift(15 downto 1);
                    lfsr_out <= shift;
                    en_out <= '0';
                end if;
            end if;
    end process;
    
    
    --16 digit counter for modifying the LFSR based on external input
    EVENT_COUNTER   :   process(clk, reset) 
        begin
            if(rising_edge(clk)) then
                if(count = 15) then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
    end process;
    
end lfsr_arch;
