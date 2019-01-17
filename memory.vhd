----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/05/2018 12:53:02 PM
-- Design Name: memory.vhd
-- Module Name: memory - memory_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: control for rw_128x32.vhd
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity memory is
    Port( 
        clk             : in    std_logic;
        reset           : in    std_logic;
        event_en        : in    std_logic;
        data_in         : in    std_logic_vector(15 downto 0);
        data_out        : out   std_logic_vector(15 downto 0)  
    );
end memory;

architecture memory_arch of memory is

--COMPONENT DECLARATIONS    
    component rw_128x16 is
        port(
            clock       : in    std_logic;
            reset       : in    std_logic;
            write       : in    std_logic;
            address     : in    std_logic_vector(15 downto 0);
            data_in     : in    std_logic_vector(15 downto 0);
            data_out    : out   std_logic_vector(15 downto 0)        
        );
    end component rw_128x16;

--SIGNALS
    signal write_en     : std_logic                         := '1';
    signal addr_int     : integer;
    signal addr_out     : std_logic_vector(15 downto 0);
    
begin

    RW_MEMORY     :   rw_128x16 
        port map(
            clock       => clk,
            reset       => reset,
            write       => write_en,
            address     => addr_out,
            data_in     => data_in,
            data_out    => data_out
        );
    
    DATA_RW : process(clk, reset)
        begin
            if(reset = '1') then
                addr_int <= 0;
                write_en <= '1';
            elsif(rising_edge(clk)) then
                if(write_en = '1' and data_in /= "0000000000000000") then
                    if(addr_int = 12) then
                        addr_int <= 0;
                        write_en <= '0';
                    else
                        addr_int <= addr_int + 1;
                    end if;
                elsif(write_en = '0') then
                    --13 address values return 7 numbers to the LEDs
                    --This is probably due to the 2 second delay on LED decoder
                    if(addr_int = 12) then
                        addr_int <= 0;
                    else
                        addr_int <= addr_int + 1;
                    end if;
                end if;
            end if;
    end process;
    
    addr_out <= std_logic_vector(to_unsigned(addr_int,16));
    

end memory_arch;
