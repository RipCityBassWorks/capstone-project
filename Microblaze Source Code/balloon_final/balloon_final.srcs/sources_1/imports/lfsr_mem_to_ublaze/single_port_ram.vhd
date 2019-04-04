library ieee;
use ieee.std_logic_1164.all;
    
entity single_port_ram is
	generic(data_width	: integer := 64;
			addr_width	: integer := 100);
	port
	(
		data	: in std_logic_vector(data_width-1 downto 0);
		addr	: in natural range 0 to addr_width-1;
		we		: in std_logic := '1';
		clk		: in std_logic;
		q		: out std_logic_vector(data_width-1 downto 0)
	);
	
end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(data_width-1 downto 0);
	type memory_t is array(addr_width-1 downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal ram : memory_t;
	
	-- Register to hold the address
	signal addr_reg : natural range 0 to addr_width - 1;

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(we = '1') then
				ram(addr) <= data;
			end if;
			
			-- Register the address for reading
			addr_reg <= addr;
		end if;
	
	end process;
	
	q <= ram(addr_reg);
	
end rtl;
