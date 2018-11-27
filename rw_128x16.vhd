----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/04/2018 09:11:15 PM
-- Design Name: rw_128x16.vhd
-- Module Name: rw_128x16 - rw_128x16_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: Read/Write memory, 128 blocks of 16 bits
-- 2,048 bits = 256 Bytes total used
-- Component of memory.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity rw_128x16 is
    port(
        clock       : in    std_logic;
        reset       : in    std_logic;
        write       : in    std_logic;
        address     : in    std_logic_vector(15 downto 0);
        data_in     : in    std_logic_vector(15 downto 0);
        data_out    : out   std_logic_vector(15 downto 0)    
    );
end entity rw_128x16;

architecture rw_128x16_arch of rw_128x16 is
    
    --array or 128 blocks of 16 bits for 2048 bit storage capacity
    type rw_type is array(0 to 127) of std_logic_vector(15 downto 0);
    
--SIGNALS    
    signal RW       : rw_type;
    signal en       : std_logic;

begin

    ENABLE : process(clock, reset)
        begin
            if(reset = '0') then
               en <= '0';
            elsif(rising_edge(clock)) then 
                if((to_integer(unsigned(address)) >= 0) and 
                    (to_integer(unsigned(address)) <= 127)) then
                    en <= '1';
                else 
                    en <= '0';
                end if;
            end if;
    end process;
    
    MEMORY : process(clock)
        begin
            if(rising_edge(clock)) then
                if(en = '1' and write = '1') then
                    RW(to_integer(unsigned(address))) <= data_in;
                    data_out <= data_in;
                elsif(en = '1' and write = '0') then
                    data_out <= RW(to_integer(unsigned(address)));
                end if;
            end if;
    end process;

end rw_128x16_arch;
