# capstone-project
Senior Capstone Project FPGA Random Number Generator

## Board Information
* Digilent Basys 3
* FPGA: Artix A7 XC7A35T-1CPG236C
* From Digilent Corp.
* Xilinx Vivado WebPACK IDE

## Function
#### Reset 
	* Set to sw(3) = 1 (active high)
#### Clock Frequency
	* User selectable at 2Hz, 5Hz, 10Hz, or 100Hz via sw(0) and sw(1)
	1. 2Hz selected at sw(0) = 0 and sw(1) = 0
	2. 5Hz selected at sw(0) = 1 and sw(1) = 0
	3. 10Hz selected at sw(0) = 0 and sw(1) = 1
	4. 100Hz selected at sw(0) = 1 and sw(1) = 1
#### LFSR (Linear Feedback Shift Register)
	* Initialized with an arbitrary 16 bit binary value
	* LFSR continuously updates with a 2 second delay between values
	* User enable inserts a '1' at a slot of LFSR determined by a 16 bit counter 
	* User enable controlled by btn(0)
#### UART Output
	* Updates at the user selected clock 
	* mem_block_in and random_out are converted to either integer or hexadecimal values 
    * Displays mem_block_in and random_out in 2 separate columns on a computer terminal
    * This way the results of the button pushes can be easily seen by the user

## Road-map

### Basys-3-Master.xdc
STATUS: complete <br />
Master XDC constants file <br />
Provided by Digilent Corp. 

### xc7_top_level.vhd
STATUS: in progress <br />
Top level VHDL file <br />
Pin I/O and component declarations

### clock_divider.vhd
STATUS: complete <br />
User selectable clock frequency <br />


### char_decoder.vhd
STATUS: complete <br />
Displays the binary value output <br />
of the LFSR as hexadecimal digits on <br />
the 7 segment display


### delay_counter.vhd
STATUS: complete <br />
2 second counter that outputs <br />
A one after 2 seconds and <br />
Outputs a zero while counting


### lfsr.vhd 
STATUS: Complete <br />
Fibonacci Linear Feedback Shift Register <br />
Used for generating hardware level <br />
16 bit Pseudo random numbers 


### rw_128x16.vhd
STATUS: in progress <br />
Memory to store and retrieve Pseudo random <br />
numbers generated from lfsr.vhd on the FPGA <br />
VHDL read/write memory model using an array of vectors


### memory.vhd 
STATUS: in progress <br />
Control for rw_128x32.vhd <br />
Populates the r/w memory with 16 bit numbers <br />
And then reads back the values <br />


### btn_debounce.vhd 
STATUS: complete <br />
control component for debouncing and <br />
synchronizing the push-buttons for future use <br />


### dflipflop.vhd 
STATUS: complete <br />
VHDL model of a d-flip-flop <br />
Used for debouncing the push buttons


### UART_TX_CTRL.vhd
STATUS: In progress <br />
Xilinx IP Core for communication to a computer <br />
Terminal over UART. The numbers stored in memory will be <br />
Sent as inputs and displayed in the computer terminal
