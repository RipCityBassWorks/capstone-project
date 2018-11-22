----------------------------------------------------------------------------------
-- Stefan Andersson 
-- 
-- Create Date: 11/03/2018 04:40:02 PM
-- Design Name: btn_debounce.vhd
-- Module Name: btn_debounce - btn_debounce_arch
-- Project Name: capstone-fpga-memory-model
-- Target Devices: XC7A35TICSG324-1L
-- Tool Versions: Vivado 2018.2 
-- Description: debounces the pushbutton(s) 
-- Component of xc7_top_level.vhd
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity btn_debounce is
    port(
        clock       : in    std_logic;
        reset       : in    std_logic;
        pb_in       : in    std_logic;
        pb_out      : out   std_logic
    );
end entity btn_debounce;

architecture btn_debounce_arch of btn_debounce is

--COMPONENT DECLARATIONS
    component dflipflop is
        port(
            clk         : in std_logic;
            Reset       : in std_logic;
            D           : in std_logic;
            Q           : out std_logic;
            Qn          : out std_logic
        );
    end component dflipflop;

--SIGNALS    
    signal Q            : std_logic;
    signal Qn           : std_logic;
    
begin

    --2 dflipflops are used to debounce and synchronize the signal
	DFLIPFLOP_1		: dflipflop		
	   port map(
	       clk         => clock, 
	       reset       => reset, 
	       D           => pb_in, 
	       Q           => Q, 
	       Qn          => Qn
	   );
	
	DFLIPFLOP_2		: dflipflop		
          port map(
              clk         => clock, 
              reset       => reset, 
              D           => Q, 
              Q           => pb_out, 
              Qn          => Qn
          );

end btn_debounce_arch;
