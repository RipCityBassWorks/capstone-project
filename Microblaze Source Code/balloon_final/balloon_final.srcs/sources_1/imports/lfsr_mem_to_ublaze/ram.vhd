library ieee;
use ieee.std_logic_1164.all;
    
entity ram is
	generic(data_width	: integer := 64;
			addr_width	: integer := 100);
	port
	(
		data_in	: in std_logic_vector(data_width-1 downto 0);
		addr	: in integer range 0 to addr_width-1;
		we		: in std_logic := '1';
		clk		: in std_logic;
		data_out		: out std_logic_vector(data_width-1 downto 0)
	);
end entity;

architecture behavorial of ram is
	subtype word_t is std_logic_vector(data_width - 1 downto 0);
	type memory_t is array(addr_width-1 downto 0) of word_t;
	
	signal mem : memory_t;
	
	signal addr_reg : integer range 0 to addr_width-1;
	
begin

	process(clk)
	begin
		if(rising_edge(clk)) then
		    
			if(we = '1') then
				mem(addr) <= data_in;
			end if;
		addr_reg <= addr;
		end if;
	end process;
	data_out <= mem(addr_reg);
end behavorial;