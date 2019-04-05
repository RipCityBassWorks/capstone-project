----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 10/18/2018 04:38:16 PM
-- Design Name: xc7_top_level.vhd
-- Module Name: xc7_top_level - xc7_top_level_arch
-- Project Name: capstone-fpga-memory-model 
-- Target Devices: XC7A35TICSG324-1L
-- Tool Versions: Vivado 2018.2
-- Description: Top level file
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity xc7_top_level is
    Port(--Clock signal
        CLK100MHZ           : in    std_logic;
        --Switches
        sw                  : in    std_logic_vector(1 downto 0);
        --LEDs
        led                 : out   std_logic_vector(1 downto 0);
        --Seven Segment Display
        an                  : out   std_logic_vector(3 downto 0);
        --PMOD Ports
        JA                  : in    std_logic_vector(7 downto 0);
        JB                  : in    std_logic_vector(7 downto 0);
        JC                  : in    std_logic_vector(7 downto 0);
        --USB-UART Interface
        UART_TXD            : out   std_logic
    );
end entity xc7_top_level;

architecture xc7_top_level_arch of xc7_top_level is
    
--COMPONENT DECLARATIONS    
    component lfsr is
        port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            en              : in    std_logic;
            reg_in          : in    std_logic_vector(15 downto 0);
            en_out          : out   std_logic;
            lfsr_out        : out   std_logic_vector(15 downto 0)
        );
    end component lfsr;
    
    component delay_counter is
        port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            delay_out       : out   std_logic
        );
    end component delay_counter;
    
    component UART_TX_CTRL is
        port( 
            CLK             : in    std_logic;
            SEND            : in    std_logic;
            DATA            : in    std_logic_vector(7 downto 0);
            READY           : out   std_logic;
            UART_TX         : out   std_logic
        );
    end component UART_TX_CTRL;
    
    
--UART DECLARATIONS   
    --State Type Declaration 
    type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0); --a type defined as an array of std_logic_vector, this is what we use to send bytes over UART
    type UART_STATE_TYPE is (RST_REG, LD_INIT_STR, SEND_CHAR, RDY_LOW, WAIT_RDY, WAIT_BTN, LD_BTN_STR);
    
    --SIGNALS and constants  
    constant RESET_CNTR_MAX     : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms
    constant MAX_STR_LEN        : integer := 15;
    constant WELCOME_STR_LEN    : natural := 15;
    
    --UART Welcome Message
    constant WELCOME_STR        : CHAR_ARRAY(0 to 14) := (
                                                            X"0A",  --\n
                                                            X"0A",  --\n
                                                            X"0D",  --\r
                                                            X"20",  --
                                                            X"4D",  --M 
                                                            X"53",  --S
                                                            X"55",  --U
                                                            X"20",  --
                                                            X"54",  --T
                                                            X"52",  --R
                                                            X"4E",  --N
                                                            X"47",  --G
                                                            X"0A",  --\n
                                                            X"0A",  --\n
                                                            X"0D"   --\r
                                                        ); 
                                                          
    constant NEW_LINE           : CHAR_ARRAY(0 to 1) := (
                                                            X"0A",  --\n
                                                            X"0D"   --\r  
                                                        ); 
                                                
    constant VERT_LINE          : CHAR_ARRAY(0 to 2) := (
                                                            X"20",  --'space'
                                                            X"7C",  --|
                                                            X"20"   --'space'
                                                        ); 
                                                        
    constant SPACE              : CHAR_ARRAY(0 to 2) := (
                                                            X"20",  --'space'
                                                            X"20",  --'space'
                                                            X"20"   --'space'
                                                        );                                                         
                                            
    constant ONE                : CHAR_ARRAY(0 to 2) := (
                                                            X"20",  --'space'
                                                            X"31",  --'1'
                                                            x"20"   --'space' 
                                                        );
                                                                                          
    constant ZERO               : CHAR_ARRAY(0 to 2) := (
                                                            X"20",  --'space'
                                                            X"30",  --'0'
                                                            x"20"   --'space' 
                                                        );    
														
    constant RANDOM_NUM         : CHAR_ARRAY(0 to 2) := (
															X"20",  --'space'
															X"58",  --'X'
															x"20"   --'space' 
														);  
                                                                                                                                                              
    --UART_TX_CTRL signals
    signal uartRdy              : std_logic;
    signal uartSend             : std_logic := '0';
    signal uartData             : std_logic_vector (7 downto 0):= "00000000";
    signal uartTX               : std_logic;
    signal dataCHAR             : CHAR_ARRAY(0 to 3);   --CHAR_ARRAY to hold output of the LFSR
    signal uartState            : UART_STATE_TYPE := RST_REG;  --Current uart state signal
    signal sendStr              : CHAR_ARRAY(0 to (MAX_STR_LEN - 1));    --Contains the current string being sent over uart.
    signal strEnd               : natural;  --Contains the length of the current string being sent over uart.
    signal strIndex             : natural;   --Contains the index of the next character to be sent over uart within the sendStr variable.     
    signal reset_cntr           : std_logic_vector (17 downto 0) := (others=>'0');  --this counter counts the amount of time paused in the UART reset state
    signal tmr_tgl              : std_logic;   --Toggle bit for UART timing
    
    
--SIGNALS    
    signal reset                : std_logic                         := sw(0);
    signal delay                : std_logic;          
    signal event_en             : std_logic                         := sw(1);
    signal lfsr_out             : std_logic_vector(15 downto 0);
    signal uart_in              : std_logic_vector(31 downto 0);
    signal reg_in               : std_logic_vector(15 downto 0)     := "1010110011100001";  
    signal random_flag          : std_logic;
    
                                                               
begin    


----------------------------------
--------LFSR INTERFACE------------
----------------------------------
    
    SHIFT_REG       :   lfsr
        port map(
            clk             => CLK100MHZ,
            en              => event_en,
            reset           => reset,      
            reg_in          => reg_in,  
            en_out          => random_flag, 
            lfsr_out        => lfsr_out
        );
    
    THIRTY_SEC_DELAY  :   delay_counter
        port map(
            clk             => CLK100MHZ,
            reset           => reset,
            delay_out       => delay
        );
        
    led <= sw;
    
    an <= "1111";

     
----------------------------------
--------UART INTERFACE------------
----------------------------------
--Messages are sent on reset and when a button is pressed.
--This counter holds the UART state machine in reset for ~2 milliseconds. 
--This will complete transmission of any byte that may have been initiated  
--during FPGA configuration due to the UART_TX line being pulled low, 
--preventing a frame shift error from occurring during the first message.

    --Component used to send a byte of data over a UART line.
    INST_UART_TX_CTRL   :   UART_TX_CTRL 
        port map(
            CLK             => CLK100MHZ,
            SEND            => uartSend,
            DATA            => uartData,
            READY           => uartRdy,
            UART_TX         => uartTX 
        );
        
    UART_TMR   :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                if((reset = '0') and (delay = '1')) then -- top most check, if our timer has reached it's val then we reset the time, toggle the timer
                    tmr_tgl <= '1'; 
                else
                    tmr_tgl <= '0';
                end if;
            end if;
    end process;
        
    DATA_ASSIGNMENT :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                dataCHAR(0) <= uart_in(31 downto 24);
                dataCHAR(1) <= uart_in(23 downto 16);
                dataChar(2) <= uart_in(15 downto 8);
                dataChar(3) <= uart_in(7 downto 0);
            end if;
    end process;  
        
    UART_RESET  :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                if((reset_cntr = RESET_CNTR_MAX) or (uartState /= RST_REG)) then
                    reset_cntr <= (others => '0');
                else
                    reset_cntr <= std_logic_vector(unsigned(reset_cntr) + 1);
                end if;
            end if;
    end process;
        
    --Next UART state logic (states described above)
    NEXT_UART_STATE :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then   
                case uartState is 
                    when RST_REG =>
                        if(reset_cntr = RESET_CNTR_MAX) then
                            uartState <= LD_INIT_STR;
                        end if;
                    when LD_INIT_STR =>
                        uartState <= SEND_CHAR;
                    when SEND_CHAR =>
                        uartState <= RDY_LOW;
                    when RDY_LOW =>
                        uartState <= WAIT_RDY;
                    when WAIT_RDY =>
                        if(uartRdy = '1') then
                            if (strEnd = strIndex) then
                                uartState <= WAIT_BTN;
                            else
                                uartState <= SEND_CHAR;
                            end if;
                        end if;
                    when WAIT_BTN =>
                        if(tmr_tgl = '1') then -- by adding tmr_tgl this should only send data when our counter finishes
                            uartState <= LD_BTN_STR; 
                        end if;
                    when LD_BTN_STR =>
                        uartState <= SEND_CHAR;
                    when others=> --should never be reached
                        uartState <= RST_REG;
                end case;
            end if;
    end process;
        
    --Loads the sendStr and strEnd signals when a LD state is reached
    STRING_LOAD  :  process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                if(uartState = LD_INIT_STR) then
                    sendStr <= WELCOME_STR;
                    strEnd <= WELCOME_STR_LEN;
                elsif(uartState = LD_BTN_STR) then
                     if((reset = '0') and (random_flag = '1')) then
                         sendStr(0 to 1) <= NEW_LINE;
                         sendStr(2 to 4) <= VERT_LINE;
                         sendStr(5 to 8) <= dataCHAR;
                         sendStr(9 to 11) <= VERT_LINE;
                         sendStr(12 to 14) <= RANDOM_NUM;
                         strEnd <= 15;
                     elsif(reset = '0') then
                        sendStr(0 to 1) <= NEW_LINE;
                        sendStr(2 to 4) <= VERT_LINE;
                        sendStr(5 to 8) <= dataCHAR;
                        sendStr(9 to 11) <= VERT_LINE;
                        sendStr(12 to 14) <= SPACE;
                        strEnd <= 15;
                    end if;
                end if;
            end if;
    end process;
        
    --Controls the strIndex signal so that it contains the index
    --of the next character that needs to be sent over UART
    CHAR_COUNT  :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                if(uartState = LD_INIT_STR or uartState = LD_BTN_STR) then
                    strIndex <= 0;
                elsif(uartState = SEND_CHAR) then
                    strIndex <= strIndex + 1;
                end if;
            end if;
    end process;
        
    --Controls the UART_TX_CTRL signals
    CHAR_LOAD   :   process(CLK100MHZ, reset)
        begin
            if (rising_edge(CLK100MHZ)) then
                if(uartState = SEND_CHAR) then 
                    uartSend <= '1';
                    uartData <= sendStr(strIndex);
                else
                    uartSend <= '0';
                end if;
            end if;
    end process;
    
    CONVERT_TO_HEX  :   process(CLK100MHZ, reset, LFSR_out)
        begin
            if(rising_edge(CLK100MHZ)) then
                case LFSR_out(15 downto 12) is
                    when "0000" => uart_in(31 downto 24) <= X"30";
                    when "0001" => uart_in(31 downto 24) <= X"31";
                    when "0010" => uart_in(31 downto 24) <= X"32";
                    when "0011" => uart_in(31 downto 24) <= X"33";
                    when "0100" => uart_in(31 downto 24) <= X"34";
                    when "0101" => uart_in(31 downto 24) <= X"35";
                    when "0110" => uart_in(31 downto 24) <= X"36";
                    when "0111" => uart_in(31 downto 24) <= X"37";
                    when "1000" => uart_in(31 downto 24) <= X"38";
                    when "1001" => uart_in(31 downto 24) <= X"39";
                    when "1010" => uart_in(31 downto 24) <= X"41";
                    when "1011" => uart_in(31 downto 24) <= X"42";
                    when "1100" => uart_in(31 downto 24) <= X"43";
                    when "1101" => uart_in(31 downto 24) <= X"44";
                    when "1110" => uart_in(31 downto 24) <= X"45";
                    when "1111" => uart_in(31 downto 24) <= X"46";
                end case;
                
                case LFSR_out(11 downto 8) is
                    when "0000" => uart_in(23 downto 16) <= X"30";
                    when "0001" => uart_in(23 downto 16) <= X"31";
                    when "0010" => uart_in(23 downto 16) <= X"32";
                    when "0011" => uart_in(23 downto 16) <= X"33";
                    when "0100" => uart_in(23 downto 16) <= X"34";
                    when "0101" => uart_in(23 downto 16) <= X"35";
                    when "0110" => uart_in(23 downto 16) <= X"36";
                    when "0111" => uart_in(23 downto 16) <= X"37";
                    when "1000" => uart_in(23 downto 16) <= X"38";
                    when "1001" => uart_in(23 downto 16) <= X"39";
                    when "1010" => uart_in(23 downto 16) <= X"41";
                    when "1011" => uart_in(23 downto 16) <= X"42";
                    when "1100" => uart_in(23 downto 16) <= X"43";
                    when "1101" => uart_in(23 downto 16) <= X"44";
                    when "1110" => uart_in(23 downto 16) <= X"45";
                    when "1111" => uart_in(23 downto 16) <= X"46";
                end case;
                
                case LFSR_out(7 downto 4) is
                    when "0000" => uart_in(15 downto 8) <= X"30";
                    when "0001" => uart_in(15 downto 8) <= X"31";
                    when "0010" => uart_in(15 downto 8) <= X"32";
                    when "0011" => uart_in(15 downto 8) <= X"33";
                    when "0100" => uart_in(15 downto 8) <= X"34";
                    when "0101" => uart_in(15 downto 8) <= X"35";
                    when "0110" => uart_in(15 downto 8) <= X"36";
                    when "0111" => uart_in(15 downto 8) <= X"37";
                    when "1000" => uart_in(15 downto 8) <= X"38";
                    when "1001" => uart_in(15 downto 8) <= X"39";
                    when "1010" => uart_in(15 downto 8) <= X"41";
                    when "1011" => uart_in(15 downto 8) <= X"42";
                    when "1100" => uart_in(15 downto 8) <= X"43";
                    when "1101" => uart_in(15 downto 8) <= X"44";
                    when "1110" => uart_in(15 downto 8) <= X"45";
                    when "1111" => uart_in(15 downto 8) <= X"46";
                end case;
                
                case LFSR_out(3 downto 0) is
                    when "0000" => uart_in(7 downto 0) <= X"30";
                    when "0001" => uart_in(7 downto 0) <= X"31";
                    when "0010" => uart_in(7 downto 0) <= X"32";
                    when "0011" => uart_in(7 downto 0) <= X"33";
                    when "0100" => uart_in(7 downto 0) <= X"34";
                    when "0101" => uart_in(7 downto 0) <= X"35";
                    when "0110" => uart_in(7 downto 0) <= X"36";
                    when "0111" => uart_in(7 downto 0) <= X"37";
                    when "1000" => uart_in(7 downto 0) <= X"38";
                    when "1001" => uart_in(7 downto 0) <= X"39";
                    when "1010" => uart_in(7 downto 0) <= X"41";
                    when "1011" => uart_in(7 downto 0) <= X"42";
                    when "1100" => uart_in(7 downto 0) <= X"43";
                    when "1101" => uart_in(7 downto 0) <= X"44";
                    when "1110" => uart_in(7 downto 0) <= X"45";
                    when "1111" => uart_in(7 downto 0) <= X"46";
                end case;
        end if;
    end process;
        
    UART_TXD <= uartTX;
                   
    
end xc7_top_level_arch;