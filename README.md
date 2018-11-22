# capstone-project
Senior Capstone Project FPGA Random Number Generator

## Board Information
* Digilent Basys 3
* FPGA: Artix A7 XC7A35T-1CPG236C
* From Digilent Corp.
* Xilinx Vivado WebPACK IDE

## Function
#### Reset 
	* Set to sw(3) = 0 (active low)
#### Clock Frequency
	* User selectable at 2Hz, 5Hz, 10Hz, or 10kHz via sw(0) and sw(1)
	1. 2Hz selected at sw(0) = 0 and sw(1) = 0
	2. 5Hz selected at sw(0) = 1 and sw(1) = 0
	3. 10Hz selected at sw(0) = 0 and sw(1) = 1
	4. 10kHz selected at sw(0) = 1 and sw(1) = 1
#### LFSR (Linear Feedback Shift Register)
	* Initialized with an arbitrary 16 bit binary value
	* LFSR continuously updates at the user selected clock
	* Output of LFSE is mem_block_in
	* mem_block_in is a 16 bit binary value
#### Enable for LFSR
	* Simulates a single event effect 
	* btn(0) = 1 is the enable condition
	* Upon enable, bit 14 of the LFSR is set to the result of (bit 0 xor bit 1)
	* Output from the LFSR with enable is random_out
	* random_out is a 16 bit binary value
    * random_out <= 0 when btn(0) = 0
    * random_out <= LFSR output when btn(0) = 1
#### UART Output
	* Updates at the same user selected clock
	* mem_block_in and random_out are converted to either integer or hexadecimal values 
    * Displays mem_block_in and random_out in 2 separate columns on a computer terminal
    * This way the results of the button pushes can be easily seen by the user
#### R/W Memory
	* Each non-zero value of random_out is stored in a 128 block array of 16 bit memory 
	* When btn(0) = 1, the bottom 8 bits of random_out are flashed on the LEDs 
	* LED output is read from left to right and top to bottom
	* When 8 instances of random_out are stored in memory, the memory is then read in a loop
	* The output from the memory reads is now the output of the LEDs

## Road-map

### Arty-A7-35-Master.xdc
STATUS: complete <br />
Master XDC constants file <br />
Provided by Digilent Corp. 

### xc7_top_level.vhd
STATUS: in progress <br />
Top level VHDL file <br />
Pin I/O and component declarations

### clock_divider.vhd
STATUS: complete <br />
Scales down the clock so that the LED output <br />
Is visible whenever a new number is generated


### led_decoder.vhd
STATUS: complete <br />
Converts the binary values stored <br />
in memory to signals for the LEDs


### delay_counter.vhd
STATUS: complete <br />
1.5 second counter that output <br />
A one after 1.5 seconds and <br />
Outputs a zero during counting 


### lfsr.vhd 
STATUS: Complete <br />
Linear Feedback Shift Register <br />
Used for generating hardware level <br />
32 bit Pseudo random numbers 


### rw_128x32.vhd
STATUS: needs testing + debugging <br />
Memory to store and retrieve Pseudo random <br />
numbers generated from lfsr.vhd on the FPGA <br />
VHDL read/write memory model using an array of vectors


### memory.vhd 
STATUS: needs testing + debugging <br />
Control for rw_128x32.vhd <br />
Populates the r/w memory with 32 bit numbers <br />
And then reads back the values <br />


### btn_debounce.vhd 
STATUS: complete <br />
control component for debouncing and <br />
synchronizing the push-buttons for future use <br />


### dflipflop.vhd 
STATUS: complete <br />
VHDL model of a d-flip-flop <br />
Used for debouncing the push buttons


### UART IP Core
STATUS: In progress <br />
Xilinx IP Core for communication to a computer <br />
Terminal over UART. The numbers stored in memory will be <br />
Sent as inputs and displayed in the computer terminal
