# capstone-project
Senior Capstone Project FPGA Random Number Generator

## Board Information
* Digilent Basys 3
* FPGA: Artix A7 XC7A35T-1CPG236C
* From Digilent Corp.
* Xilinx Vivado WebPACK IDE

## Information 
This is the production code for an FPGA based random number generator. <br />
This is for a senior capstone project with the goal of generating <br />
truly random number using single event effects from ionizing <br />
radiation in the upper atmosphere. The FPGA system will be sent <br />
to the upper atmosphere on a high altitude balloon. <br />
#### This project contains 
	* MicroBlaze soft-processor
	* Massive memory blocks
	* Triplicated MicroSD cards through the Digilent PMOD interface
	* LFSR system
	* UART interface 
The MicroBlaze processor initializes all memory blocks to hold ones <br />
and then continually scans every memory address synchronously to check <br />
for bit flips caused by single event effects. When a bit flip is detected <br />
the MicroBlaze triggers the enable condition for the LFSR and a truly <br />
random number is generated. The output of the LFSR, along with bit flip <br />
information is stored in a triplicated microSD system for failure prevention. <br />
Additionally, the output of the LFSR is monitored over a UART connection with <br />
a very slow data stream to see any potential errors in close to real time. 

## Function
#### Reset 
	* Set to sw(0) = 1 (active high)
#### LFSR (Linear Feedback Shift Register)
	* Initialized with an arbitrary 16 bit binary value
	* LFSR continuously updates at system clock
	* External enable modifies the LFSR output
	* LFSR modification is based on the current value of a 16
	* digit counter, the value of this corresponds to the bit 
	* of the LFSR to be flipped
	* Reset condition restarts the LFSR starting with the original seed
#### UART Output
	* 8 data bits, LSB first
	* 1 stop bit 
	* no parity bit
	* 115200 Baud rate
	* Updates at system clock
	* 30 second delay between each data stream
	* lfsr_out is converted to the ASCII representation of hexadecimal characters
	* Terminal output displays the hexadecimal LFSR result along with a 'X' 
	* indicating a modified LFSR output
	* Reset condition pauses the data stream
	* Data stream resumes when reset = '0'
#### Delay Counter
	* 30 second delay for the UART 
	* Uses a counter 

## Road-map

### Basys-3-Master.xdc
STATUS: complete <br />
Master XDC constants file <br />
Provided by Digilent Corp. 

### xc7_top_level.vhd
STATUS: complete <br />
Top level VHDL file <br />
Pin I/O and component declarations

### delay_counter.vhd
STATUS: complete <br />
30 second counter that outputs <br />
A one after 30 seconds and <br />
Outputs a zero while counting

### lfsr.vhd 
STATUS: Complete <br />
Fibonacci Linear Feedback Shift Register <br />
Used for generating hardware level <br />
16 bit Pseudo random numbers 

### UART_TX_CTRL.vhd
STATUS: complete <br />
Xilinx IP Core for communication over UART <br />
Has been modified for a 11520 Baud rate <br />
and a 15 byte output sent over a 8 bit data <br />
stream 
