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
-- User input can insert a 1 in a slot of the vector
-- Determined by a 16 digit counter 
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity lfsr is
    port(
        sys_clk     : in    std_logic;
        clock       : in    std_logic;
        reset       : in    std_logic;
        en          : in    std_logic;
        reg_in      : in    std_logic_vector(15 downto 0);
        lfsr_out    : out   std_logic_vector(15 downto 0);
        random_out  : out   std_logic_vector(15 downto 0)
    );
end entity lfsr;

architecture lfsr_arch of lfsr is

--COMPONENT DECLARATIONS  
    component delay_counter is
        port(
            clock           : in    std_logic;
            reset           : in    std_logic;
            delay_out       : out   std_logic
        );
    end component delay_counter;
    
--SIGNALS    
    signal shift    	: std_logic_vector(15 downto 0)  := reg_in;
    signal delay        : std_logic;
    signal xor_out      : std_logic;
    signal count        : integer;

begin
    
    TWO_SEC_DELAY  :   delay_counter
        port map(
            clock           => sys_clk,
            reset           => reset,
            delay_out       => delay
        );
    
    
    LINEAR_FEEDBACK_SHIFT_REGISTER  :   process(sys_clk, reset, en, reg_in)
        begin
            if(reset = '1') then
                shift <= reg_in;
            elsif(rising_edge(sys_clk)) then
                if(en = '1') then
                    shift(count) <= '1';
                    random_out <= shift;
                end if;
                if(delay = '1') then
                    xor_out <= shift(10) xor (shift(12) xor (shift(15) xor shift(13)));
                    shift(14 downto 0) <= shift(15 downto 1);
                    shift(15) <= xor_out;
                    lfsr_out <= shift;
                end if;
            end if;
    end process;
    
    
    EVENT_COUNTER   :   process(clock, reset) 
        begin
            if(reset = '1') then
                count <= 0;
            elsif(rising_edge(clock)) then
                if(count = 15) then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
    end process;
    
end lfsr_arch;
