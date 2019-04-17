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

Library UNISIM;
use UNISIM.vcomponents.all;


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
        
        --PMOD Ports
        JA                  : in    std_logic_vector(7 downto 0);
        JB                  : in    std_logic_vector(7 downto 0);
        JC                  : in    std_logic_vector(7 downto 0);
        JXADC               : in    std_logic_vector(7 downto 0);   --used for analog to digital conversion
        
        --USB-UART Interface
        UART_TXD            : out   std_logic
    );
end entity xc7_top_level;

architecture xc7_top_level_arch of xc7_top_level is
    
--COMPONENT DECLARATIONS
    component char_decoder is
        Port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            anode           : out   std_logic_vector(3 downto 0);
            dp              : out   std_logic;
            bin_in          : in    std_logic_vector(15 downto 0);
            hex_out         : out   std_logic_vector(6 downto 0) 
        );
    end component char_decoder;
    
    component lfsr is
        port(
            clk             : in    std_logic;
            reset           : in    std_logic;
            en              : in    std_logic;
            delay           : in    std_logic;
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
    constant MAX_STR_LEN        : integer := 34;
    constant WELCOME_STR_LEN    : natural := 34;
    
    --UART Welcome Message
    constant WELCOME_STR        : CHAR_ARRAY(0 to 33) := (
                                                            X"0D",  --\r
                                                            X"0A",  --\n
                                                            X"48",  --H
                                                            X"49",  --I
                                                            X"47",  --G
                                                            X"48",  --H
                                                            X"20",  --
                                                            X"41",  --A
                                                            X"4C",  --L
                                                            X"54",  --T
                                                            X"49",  --I 
                                                            X"54",  --T
                                                            X"55",  --U
                                                            X"44",  --D
                                                            X"45",  --E
                                                            X"20",  -- 
                                                            X"42",  --B
                                                            X"41",  --A
                                                            X"4C",  --L
                                                            X"4C",  --L
                                                            X"4F",  --O 
                                                            X"4F",  --O
                                                            X"4E",  --N
                                                            X"20",  --
                                                            X"44",  --D
                                                            X"45",  --E 
                                                            X"4D",  --M 
                                                            X"4F",  --O
                                                            X"20",  -- 
                                                            X"20",  -- 
                                                            X"0D",  --\r
                                                            X"0A",  --\n
                                                            X"0D",  --\r
                                                            X"0A"   --\n
                                                        );
                                                          
    constant NEW_LINE           : CHAR_ARRAY(0 to 1) := (
                                                            X"0D",  --\r 
                                                            X"0A"   --\n 
                                                        ); 
                                                
    constant VERT_LINE          : CHAR_ARRAY(0 to 2) := (
                                                            X"20",  --space
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


--XADC SIGNALS
    signal reading : std_logic_vector(15 downto 0) := (others => '0');
    signal muxaddr : std_logic_vector( 4 downto 0) := (others => '0');
    signal channel : std_logic_vector( 4 downto 0) := (others => '0');
    signal vauxn   : std_logic_vector(15 downto 0) := (others => '0');
    signal vauxp   : std_logic_vector(15 downto 0) := (others => '0');
    
    
--SIGNALS    
    signal clock                : std_logic;
    signal reset                : std_logic                         := sw(3);
    signal delay                : std_logic;          
    signal event_en             : std_logic;                                                --Toggles depending on the value from the XADC
    signal lfsr_out             : std_logic_vector(15 downto 0);
    signal uart_in              : std_logic_vector(31 downto 0);
    signal reg_in               : std_logic_vector(15 downto 0)     := "1010110011100001";  --the seed for the LFSR: 0xACE1
    signal random_flag          : std_logic;                                                --flag to indicate an event
    
                                                               
begin    


----------------------------------
--------LFSR INTERFACE------------
----------------------------------

    
    SEVEN_SEGMENT_DISPLAY      :   char_decoder     --Component that controls the four 7-segment displays of the Basys Board
        port map(
            clk             => CLK100MHZ,
            reset           => reset,
            anode           => an,
            dp              => dp,
            bin_in          => lfsr_out,
            hex_out         => seg
        );
    
    SHIFT_REG       :   lfsr            --Linear Feedback Shift Register with enable modifier
        port map(
            clk             => CLK100MHZ,
            en              => event_en,
            delay           => delay,
            reset           => reset,      
            reg_in          => reg_in,  
            en_out          => random_flag, 
            lfsr_out        => lfsr_out
        );
    
    TWO_SEC_DELAY  :   delay_counter        --Sets the timing for the LFSR and UART
        port map(
            clk             => CLK100MHZ,
            reset           => reset,
            delay_out       => delay
        );
    
    
----------------------------------
--------XADC INTERFACE------------
----------------------------------
    
    vauxp(6)  <= jxadc(0);  vauxn(6)  <= jxadc(4);
    vauxp(14) <= jxadc(1);  vauxn(14) <= jxadc(5);
    vauxp(7)  <= jxadc(2);  vauxn(7)  <= jxadc(6);
    vauxp(15) <= jxadc(3);  vauxn(15) <= jxadc(7);
    
    XADC_inst   :   XADC
        generic map(
            -- INIT_40 - INIT_42: XADC configuration registers
            INIT_40 => X"9000", -- averaging of 16 selected for external channels
            INIT_41 => X"2ef0", -- Continuous Seq Mode, Disable unused ALMs, Enable calibration
            INIT_42 => X"0800", -- ACLK = DCLK/8 = 100MHz / 8 = 12.5 MHz 
            -- INIT_48 - INIT_4F: Sequence Registers
            INIT_48 => X"4701", -- CHSEL1 - enable Temp VCCINT, VCCAUX, VCCBRAM, and calibration
            INIT_49 => X"000CC", -- CHSEL2 - enable aux analog channels 6,7,14,15
            INIT_4A => X"0000", -- SEQAVG1 disabled all channels
            INIT_4B => X"0000", -- SEQAVG2 disabled all channels
            INIT_4C => X"0000", -- SEQINMODE0 - The lowest 16 channels are bipolar
            INIT_4D => X"00CC", -- SEQINMODE1 - Channels 6, 7, 14 & 15 are unipolar
            INIT_4E => X"0000", -- SEQACQ0 - No extra settling time all channels
            INIT_4F => X"0000", -- SEQACQ1 - No extra settling time all channels
            -- INIT_50 - INIT_58, INIT5C: Alarm Limit Registers
            INIT_50 => X"b5ed", -- Temp upper alarm trigger 85°C
            INIT_51 => X"5999", -- Vccint upper alarm limit 1.05V
            INIT_52 => X"A147", -- Vccaux upper alarm limit 1.89V
            INIT_53 => X"dddd", -- OT upper alarm limit 125°C - see Thermal Management
            INIT_54 => X"a93a", -- Temp lower alarm reset 60°C
            INIT_55 => X"5111", -- Vccint lower alarm limit 0.95V
            INIT_56 => X"91Eb", -- Vccaux lower alarm limit 1.71V
            INIT_57 => X"ae4e", -- OT lower alarm reset 70°C - see Thermal Management
            INIT_58 => X"5999", -- VCCBRAM upper alarm limit 1.05V
            INIT_5C => X"5111", -- VCCBRAM lower alarm limit 0.95V

            -- Simulation attributes: Set for proper simulation behavior
            SIM_DEVICE       => "7SERIES",    -- Select target device (values)
            SIM_MONITOR_FILE => "design.txt"  -- Analog simulation data file name
        ) port map(
            -- ALARMS: 8-bit (each) output: ALM, OT
            ALM          => open,             -- 8-bit output: Output alarm for temp, Vccint, Vccaux and Vccbram
            OT           => open,             -- 1-bit output: Over-Temperature alarm
            
            -- STATUS: 1-bit (each) output: XADC status ports
            BUSY         => open,             -- 1-bit output: ADC busy output
            CHANNEL      => channel,          -- 5-bit output: Channel selection outputs
            EOC          => open,             -- 1-bit output: End of Conversion
            EOS          => open,             -- 1-bit output: End of Sequence
            JTAGBUSY     => open,             -- 1-bit output: JTAG DRP transaction in progress output
            JTAGLOCKED   => open,             -- 1-bit output: JTAG requested DRP port lock
            JTAGMODIFIED => open,             -- 1-bit output: JTAG Write to the DRP has occurred
            MUXADDR      => muxaddr,          -- 5-bit output: External MUX channel decode
            
            -- Auxiliary Analog-Input Pairs: 16-bit (each) input: VAUXP[15:0], VAUXN[15:0]
            VAUXN        => vauxn,            -- 16-bit input: N-side auxiliary analog input
            VAUXP        => vauxp,            -- 16-bit input: P-side auxiliary analog input
            
            -- CONTROL and CLOCK: 1-bit (each) input: Reset, conversion start and clock inputs
            CONVST       => '0',              -- 1-bit input: Convert start input
            CONVSTCLK    => '0',              -- 1-bit input: Convert start input
            RESET        => '0',              -- 1-bit input: Active-high reset
            
            -- Dedicated Analog Input Pair: 1-bit (each) input: VP/VN
            VN           => '0', -- 1-bit input: N-side analog input
            VP           => '0', -- 1-bit input: P-side analog input
            
            -- Dynamic Reconfiguration Port (DRP) -- hard set to read channel 6 (XADC4/XADC0)
            DO           => reading,
            DRDY         => open,
            DADDR        => "0010110",  -- The address for reading AUX channel 6
            DCLK         => CLK100MHZ,
            DEN          => '1',
            DI           => (others => '0'),
            DWE          => '0'
        );
       
    EVENT_DETECT    :   process(CLK100MHZ, reset, reading) is
        begin
            if(rising_edge(CLK100MHZ)) then
                if(reset = '1') then
                    event_en <= '0';
                elsif((reading(14) = '1') and (reading(15) = '0')) then     --The threshold for the laser pointer. Bit 15 will only ever equal one on startup
                    event_en <= '1';
                else
                    event_en <= '0';
                end if;
            end if;
    end process;
        
    led <= reading;         --Display the value of the XADC on the LEDs

     
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
    
    --Checks the system reset state and times data transmission for every 2 seconds    
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
    
    --Each byte of data for the current transmission is assigned to the corresponding dataCHAR    
    DATA_ASSIGNMENT :   process(CLK100MHZ, reset)
        begin
            if(rising_edge(CLK100MHZ)) then
                dataCHAR(0) <= uart_in(31 downto 24);
                dataCHAR(1) <= uart_in(23 downto 16);
                dataChar(2) <= uart_in(15 downto 8);
                dataChar(3) <= uart_in(7 downto 0);
            end if;
    end process;  
    
    --Reset condition for the UART to prevent hangs    
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
    
    --Converts each set of 4 bits from the LFSR to the ASCII representation of hexadacimal
    --These values will be sent over UART
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
        
    UART_TXD <= uartTX;     --Data will be sent over UART 1 byte at a time
                   
    
end xc7_top_level_arch;