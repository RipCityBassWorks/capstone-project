----------------------------------------------------------------------------------
-- Stefan Andersson
-- 
-- Create Date: 10/18/2018 04:38:16 PM
-- Design Name: xc7_top_level.vhd
-- Module Name: xc7_top_level - xc7_top_level_arch
-- Project Name: capstone-project
-- Target Devices: XC7A35TCPG236-1
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
        sw                  : in    std_logic_vector(15 downto 0);
        --LEDs
        led                 : out   std_logic_vector(15 downto 0);
        --Seven Segment Display
        seg                 : out   std_logic_vector(6 downto 0);
        dp                  : out   std_logic;
        an                  : out   std_logic_vector(3 downto 0);
        --Buttons
        btn                 : in    std_logic_vector(4 downto 0);
        
        --PMOD Ports Removed Temp.
        
        --USB-UART Interface
        UART_TXD            : out   std_logic
    );
end entity xc7_top_level;

architecture xc7_top_level_arch of xc7_top_level is
    
--COMPONENT DECLARATIONS
    component clock_divider is
        port(
            clk_in              : in    std_logic;
            reset               : in    std_logic;
            sel                 : in    std_logic_vector(1 downto 0);
            clk_out             : out   std_logic
        );
    end component clock_divider;
    
    component char_decoder is
        Port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            bin_in          : in    std_logic_vector(15 downto 0);
            hex_out         : out   std_logic_vector(6 downto 0) 
        );
    end component char_decoder;
    
    component lfsr is
        port(
            clock           : in    std_logic;
            reset           : in    std_logic;
            en              : in    std_logic;
            reg_in          : in    std_logic_vector(15 downto 0);
            lfsr_out        : out   std_logic_vector(15 downto 0);
            random_out      : out   std_logic_vector(15 downto 0)
        );
    end component lfsr;
    
    component memory is
        Port( 
            clk             : in    std_logic;
            reset           : in    std_logic;
            event_en        : in    std_logic;
            data_in         : in    std_logic_vector(15 downto 0);
            data_out        : out   std_logic_vector(15 downto 0) 
        );
    end component memory;
    
    component btn_debounce is 
        port(
            clock           : in    std_logic;
            reset           : in    std_logic;
            pb_in           : in    std_logic;
            pb_out          : out   std_logic
        );
    end component btn_debounce;
    
    component UART_TX_CTRL is
        Port( 
            SEND            : in  STD_LOGIC;
            DATA            : in  STD_LOGIC_VECTOR (7 downto 0);
            CLK             : in  STD_LOGIC;
            READY           : out  STD_LOGIC;
            UART_TX         : out  STD_LOGIC
        );
    end component;
    
--STATE TYPE DECLERATIONS
    type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0); --a type defined as an array of std_logic_vector, this is what we use to send bytes over UART
    type UART_STATE_TYPE is (RST_REG, LD_INIT_STR, SEND_CHAR, RDY_LOW, WAIT_RDY, WAIT_BTN, LD_BTN_STR);
--CONSTANTS 
    constant TMR_CNTR_MAX : std_logic_vector(26 downto 0) := "101111101011110000100000000"; --100,000,000 = clk cycles per second
    constant TMR_VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9
    
    constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms
    
    constant MAX_STR_LEN : integer := 31;
    
    constant WELCOME_STR_LEN : natural := 31;
    constant BTN_STR_LEN : natural := 24;
    constant COUNT_UP : integer := 50000;
    --UART Welcome Message
    constant WELCOME_STR : CHAR_ARRAY(0 to 30) := (X"0A",  --\n
                                                                  X"0D",  --\r
                                                                  X"43",  --C
                                                                  X"41",  --A
                                                                  X"50",  --P
                                                                  X"53",  --S
                                                                  X"54",  --T
                                                                  X"4F",  --O
                                                                  X"4E",  --N
                                                                  X"45",  --E
                                                                  X"20",  -- 
                                                                  X"55",  --U
                                                                  X"41",  --A
                                                                  X"52",  --R
                                                                  X"54",  --T
                                                                  X"20",  -- 
                                                                  X"4C",  --L
                                                                  X"46",  --F
                                                                  X"53",  --S
                                                                  X"52",  --R
                                                                  X"20",  -- 
                                                                  X"44",  --D
                                                                  X"45",  --E
                                                                  X"4D",  --M
                                                                  X"4F",  --O
                                                                  X"20",  -- 
                                                                  X"20",  -- 
                                                                  X"20",  -- 
                                                                  X"0A",  --\n
                                                                  X"0A",  --\n
                                                                  X"0D"); --\r
    constant NEW_LINE : CHAR_ARRAY(0 to 1) :=(X"0A",--\n
                                                X"0D"); --\r  
    constant VERT_LINE : CHAR_ARRAY(0 to 2) := (x"20", --space
                                                X"7C", --|
                                                X"20"); --'space'
    constant ONE : CHAR_ARRAY(0 to 2)       := (X"20", --'space'
                                                X"31", --'1'
                                                x"20");--'space'                                           
    constant ZERO : CHAR_ARRAY(0 to 2)       := (X"20", --'space'
                                                 X"30", --'1'
                                                 x"20");--'space'    
                                                 
--SIGNALS                                                                                                
    signal clock            : std_logic;
    signal reset            : std_logic                         := sw(3);--ck_rst;
    --btn(0) debounced
    signal pb_0             : std_logic;   
    --btn(1) debounced     
    signal pb_1             : std_logic;
    --btn(2) debounced
    signal pb_2             : std_logic;
    --btn(3) debounced
    signal pb_3             : std_logic;
    signal event_en         : std_logic                         := pb_0;
    signal mem_block_in     : std_logic_vector(15 downto 0);
    signal mem_block_out    : std_logic_vector(15 downto 0);
    signal reg_in           : std_logic_vector(15 downto 0)     := "1110000100000000";  
    signal random_out       : std_logic_vector(15 downto 0);
    signal sys_clks_sec     : std_logic_vector(31 downto 0)     := "00000101111101011110000100000000";      
          
--UART_TX_CTRL control signals
    signal uartRdy : std_logic;
    signal uartSend : std_logic := '0';
    signal uartData : std_logic_vector (7 downto 0):= "00000000";
    signal uartTX : std_logic;
    signal uartCLK : std_logic;
--CHAR_ARRAY to hold output of the LFSR
    signal dataCHAR : CHAR_ARRAY(0 to 1);   
--Current uart state signal
    signal uartState : UART_STATE_TYPE := RST_REG;
--Contains the current string being sent over uart.
    signal sendStr : CHAR_ARRAY(0 to (MAX_STR_LEN - 1));
    
--Contains the length of the current string being sent over uart.
    signal strEnd : natural;
    
--Contains the index of the next character to be sent over uart
--within the sendStr variable.
    signal strIndex : natural;        
--this counter counts the amount of time paused in the UART reset state
    signal reset_cntr : std_logic_vector (17 downto 0) := (others=>'0');  
--These signals are used to time the UART output so that it is readable
    constant tmr_val  :   integer := 50000000;
    signal tmr         :  integer :=0;
    signal tmr_tgl      : std_logic;      
                                                            
begin    
   
    PUSH_BUTTON_ZERO    :   btn_debounce
        port map(
            clock       => CLK100MHZ,
            reset       => reset,
            pb_in       => btn(0),
            pb_out      => pb_0
        );
    
    PUSH_BUTTON_ONE    :   btn_debounce
        port map(
            clock       => CLK100MHZ,
            reset       => reset,
            pb_in       => btn(1),
            pb_out      => pb_1
        ); 
        
    PUSH_BUTTON_TWO    :   btn_debounce
        port map(
            clock       => CLK100MHZ,
            reset       => reset,
            pb_in       => btn(2),
            pb_out      => pb_2
        );  
    
    PUSH_BUTTON_THREE    :   btn_debounce
        port map(
            clock       => CLK100MHZ,
            reset       => reset,
            pb_in       => btn(3),
            pb_out      => pb_3
        ); 
        
    DIVIDE_CLOCK    :   clock_divider   
        port map(
            clk_in      => CLK100MHZ, 
            reset       => reset, 
            sel         => sw(1 downto 0), 
            clk_out     => clock
        );
        
    SEVEN_SEGMENT_DISPLAY      :   char_decoder
        port map(
            clk         => clock,
            reset       => reset,
            bin_in      => mem_block_out,
            hex_out     => seg
        );
        
    SHIFT_REG       :   lfsr
        port map(
            clock       => clock,
            en          => event_en,
            reset       => reset,      
            reg_in      => reg_in,   
            lfsr_out    => mem_block_in,
            random_out  => random_out 
        );
    
    RW_MEMORY       :   memory
        port map(
            clk         => clock,
            reset       => reset,
            event_en    => event_en,
            data_in     => random_out,
            data_out    => mem_block_out
        );

        an <= "0111";
        dp <= '1';
               
        ----------------------------------------------------------
        ------              UART Control                   -------
        ----------------------------------------------------------
        --Messages are sent on reset and when a button is pressed.
        
        --This counter holds the UART state machine in reset for ~2 milliseconds. This
        --will complete transmission of any byte that may have been initiated during 
        --FPGA configuration due to the UART_TX line being pulled low, preventing a 
        --frame shift error from occuring during the first message.
        
        UART_TMR   :   process(CLK100MHZ)
            begin
                if(rising_edge(CLK100MHZ)) then
                    if(tmr = tmr_val) then --top most check, if our timer has reached it's val then we reset the time, toggle the toggle
                        tmr <= 0;
                        tmr_tgl <= '1';
                    elsif(tmr < tmr_val and tmr_tgl = '1') then --this ensures the toggle bit is only set for one CLK100MHZ cycle
                        tmr_tgl <= '0';
                    else
                        tmr <= tmr + 1;     --if our timer hasn't counted up and our toggle bit is 0 then we increment the timer value
                    end if;
                end if;
        end process;
        
        process(CLK100MHZ)
            begin
                if rising_edge(CLK100MHZ) then
                    dataCHAR(0) <= mem_block_in(15 downto 8);
                    dataCHAR(1) <= mem_block_in(7 downto 0);
                else
                end if;
        end process;
        
        
        process(CLK100MHZ)
        begin
          if (rising_edge(CLK100MHZ)) then
            if ((reset_cntr = RESET_CNTR_MAX) or (uartState /= RST_REG)) then
              reset_cntr <= (others=>'0');
            else
              reset_cntr <= std_logic_vector(unsigned(reset_cntr) + 1);
            end if;
          end if;
        end process;
        
        --Next Uart state logic (states described above)
        next_uartState_process : process (CLK100MHZ)
        begin
            if (rising_edge(CLK100MHZ)) then
                    
                    case uartState is 
                    when RST_REG =>
                if (reset_cntr = RESET_CNTR_MAX) then
                  uartState <= LD_INIT_STR;
                end if;
                    when LD_INIT_STR =>
                        uartState <= SEND_CHAR;
                    when SEND_CHAR =>
                        uartState <= RDY_LOW;
                    when RDY_LOW =>
                        uartState <= WAIT_RDY;
                    when WAIT_RDY =>
                        if (uartRdy = '1') then
                            if (strEnd = strIndex) then
                                uartState <= WAIT_BTN;
                            else
                                uartState <= SEND_CHAR;
                            end if;
                        end if;
                    when WAIT_BTN =>
                        if (sw(3) = '1' and tmr_tgl = '1') then -- by adding tmr_tgl this should only send data when our counter finishes
                            uartState <= LD_BTN_STR;
                            
                        end if;
                    when LD_BTN_STR =>
                        uartState <= SEND_CHAR;
                    when others=> --should never be reached
                        uartState <= RST_REG;
                    end case;
                
            end if;
        end process;
        
        --Loads the sendStr and strEnd signals when a LD state is
        --is reached.
        string_load_process : process (CLK100MHZ)
        begin
            if (rising_edge(CLK100MHZ)) then
                if (uartState = LD_INIT_STR) then
                    sendStr <= WELCOME_STR;
                    strEnd <= WELCOME_STR_LEN;
                elsif (uartState = LD_BTN_STR) then
                    if(pb_0 = '1') then
                        sendStr(0 to 1) <= NEW_LINE;
                        sendStr(2 to 4) <= VERT_LINE;
                        sendStr(5 to 7) <= ONE;
                        sendStr(8 to 10) <= VERT_LINE;
                        sendStr(11 to 12)<= dataCHAR;
                        sendStr(13 to 15)<= VERT_LINE;
                        strEnd <= 16;
                    else
                        sendStr(0 to 1) <= NEW_LINE;
                        sendStr(2 to 4) <= VERT_LINE;
                        sendStr(5 to 7) <= ZERO;
                        sendStr(8 to 10) <= VERT_LINE;
                        sendStr(11 to 12)<= dataCHAR;
                        sendStr(13 to 15)<= VERT_LINE;
                        strEnd <= 16;
                    end if;
                end if;
            end if;
        end process;
        
        --Conrols the strIndex signal so that it contains the index
        --of the next character that needs to be sent over uart
        char_count_process : process (CLK100MHZ)
        begin
            if (rising_edge(CLK100MHZ)) then
                if (uartState = LD_INIT_STR or uartState = LD_BTN_STR) then
                    strIndex <= 0;
                elsif (uartState = SEND_CHAR) then
                    strIndex <= strIndex + 1;
                end if;
            end if;
        end process;
        
        --Controls the UART_TX_CTRL signals
        char_load_process : process (CLK100MHZ)
        begin
            if (rising_edge(CLK100MHZ)) then
                if (uartState = SEND_CHAR) then 
                    uartSend <= '1';
                    uartData <= sendStr(strIndex);
                else
                    uartSend <= '0';
                end if;
            end if;
        end process;
        
        --Component used to send a byte of data over a UART line.
        Inst_UART_TX_CTRL: UART_TX_CTRL port map(
                SEND => uartSend,
                DATA => uartData,
                CLK => CLK100MHZ,
                READY => uartRdy,
                UART_TX => uartTX 
            );
        
        UART_TXD <= uartTX;
                   
    
end xc7_top_level_arch;
