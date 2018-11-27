----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 11/26/2018 09:13:01 PM
-- Design Name: char_decoder.vhd
-- Module Name: char_decoder - char_decoder_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
-- Tool Versions: Vivado 2018.2
-- Description: Hexidecimal decoder 
-- Displays a 16 bit value on the 7 segment display
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity char_decoder is
    Port(
        clk             : in    std_logic;
        reset           : in    std_logic;
        bin_in          : in    std_logic_vector(15 downto 0);
        hex_out         : out   std_logic_vector(6 downto 0) 
    );
end char_decoder;

architecture char_decoder_arch of char_decoder is

    begin
		process(bin_in)
			begin
				case(bin_in) is
					when "0000" => hex_out <= "1000000";
					when "0001" => hex_out <= "1111001";
					when "0010" => hex_out <= "0100100";
					when "0011" => hex_out <= "0110000";
					
					when "0100" => hex_out <= "0011001";
					when "0101" => hex_out <= "0010010";
					when "0110" => hex_out <= "0000010";
					when "0111" => hex_out <= "1111000";
					
					when "1000" => hex_out <= "0000000";
					when "1001" => hex_out <= "0010000";
					when "1010" => hex_out <= "0001000";
					when "1011" => hex_out <= "0000011";
					
					when "1100" => hex_out <= "0100111";
					when "1101" => hex_out <= "0100001";
					when "1110" => hex_out <= "0000110";
					when "1111" => hex_out <= "0001110";	
				end case;
		end process;


end char_decoder_arch;
