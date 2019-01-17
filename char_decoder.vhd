----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/26/2018 09:13:01 PM
-- Design Name: char_decoder.vhd
-- Module Name: char_decoder - char_decoder_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: 7 segment display hexadecimal character decoder 
-- Displays a 16 bit value on the 7 segment display
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity char_decoder is
    Port(
        clk             : in    std_logic;
        reset           : in    std_logic;
        anode           : out   std_logic_vector(3 downto 0);
        dp              : out   std_logic;
        bin_in          : in    std_logic_vector(15 downto 0);
        hex_out         : out   std_logic_vector(6 downto 0) 
    );
end char_decoder;

architecture char_decoder_arch of char_decoder is

--COMPONENT DECLARATIONS    
    component display_counter is
        port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            seg_sel         : out   std_logic_vector(1 downto 0)
        );
    end component display_counter;
    
--SIGNALS 
    signal segment          : std_logic_vector(3 downto 0);
    signal seg_sel          : std_logic_vector(1 downto 0);            
    signal an               : std_logic_vector(3 downto 0);
    
    begin
    
    TIMER   :   display_counter
        port map(
            clk         => clk,
            reset       => reset,
            seg_sel     => seg_sel
        );
        
        process(segment) 
            begin
                case(segment) is
                    when "0000" => hex_out <= "1000000"; -- 0
                    when "0001" => hex_out <= "1111001"; -- 1
                    when "0010" => hex_out <= "0100100"; -- 2
                    when "0011" => hex_out <= "0110000"; -- 3
                    
                    when "0100" => hex_out <= "0011001"; -- 4
                    when "0101" => hex_out <= "0010010"; -- 5
                    when "0110" => hex_out <= "0000010"; -- 6
                    when "0111" => hex_out <= "1111000"; -- 7
                    
                    when "1000" => hex_out <= "0000000"; -- 8
                    when "1001" => hex_out <= "0010000"; -- 9
                    when "1010" => hex_out <= "0100000"; -- a
                    when "1011" => hex_out <= "0000011"; -- b
                    
                    when "1100" => hex_out <= "1000110"; -- C
                    when "1101" => hex_out <= "0100001"; -- d
                    when "1110" => hex_out <= "0000110"; -- E
                    when "1111" => hex_out <= "0001110"; -- F
                end case;
        end process;
    
		process(reset, seg_sel, bin_in)
            begin
                case(seg_sel) is
                    when "00" => 
                                an <= "0111";                       -- activate LED1 and Deactivate LED2, LED3, LED4
                                segment <= bin_in(15 downto 12);
                    when "01" =>
                                an <= "1011";                       -- activate LED2 and Deactivate LED1, LED3, LED4
                                segment <= bin_in(11 downto 8);
                    when "10" =>
                                an <= "1101";                       -- activate LED3 and Deactivate LED2, LED1, LED4
                                segment <= bin_in(7 downto 4);
                    when "11" =>
                                an <= "1110";                       -- activate LED4 and Deactivate LED2, LED3, LED1
                                segment <= bin_in(3 downto 0);
                end case;
		end process;
        
        anode <= an;
        dp <= '1';

end char_decoder_arch;
