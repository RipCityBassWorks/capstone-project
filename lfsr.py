## Stefan Andersson
## Created on 04/13/2019
##
## Python Based Fibonaci LFSR with a Serial Interface
### Acts as the control for the random number generator
### capstone project
### Reads in the LFSR output from an FPGA
### Outputs the numbers generated from the LFSR
### Along with the feed from the FPGA
##
## Linear Feedback Shift Register
### Seed: ACE1
### Taps at bits 0, 2, 3, and 5
### Right shift
##
## Serial Interface
### Port: COM9 (USB) - will need to be set by the user
### Baud: 115200
### Byte size: 8 bits
### Parity: none
### Timout: 10s


import serial


class lfsr:


    def __init__(self, seed):
        while(True):    #infinite loop used to continue the program if the FPGA is disconnected
            try:
                self.ser = serial.Serial("COM9", 115200, timeout=10, bytesize=serial.EIGHTBITS)     #creates a new instance of pyserial
                self.printWelcome()
                self.num = seed         #the first value of the LFSR is the seed
                self.printResult()
                while(True):    #loop to output the numbers from the software and hardware LFSRs. Loop breaks when the serial connection is lost
                    self.shiftSequence()
                    self.printResult()
            except serial.SerialException:      #catches the exception triggered by the device being disconnected and waits for reconnection
                continue;


    #Function to generate the next value of the LFSR
    def shiftSequence(self):
        xor_out = ((self.num >> 5 & 1) ^ ((self.num >> 3 & 1) ^ ((self.num >> 2 & 1) ^ (self.num >> 0 & 1))))   #result of LFSR taps
        mask = 1 << 15
        self.num = self.num >> 1
        self.num = ((self.num & ~mask) | ((xor_out << 15) & mask))      #value in xor_out is placed in bit 15 of the result
        

    #Function to print the current value of the LFSR to the terminal
    def printResult(self):
        wait = True;
        while(wait):
            if(self.ser.in_waiting):    #waits for the next value sent over UART to reach the input buffer
                input_text = self.ser.readline().decode("ascii")
                print("\t\t\t\t\t\t", " ", " |", "%04X" % self.num, "|", "    --   ", input_text)      #prints the results in hexadecimal self.ser.read_until().decode("utf-8")
                wait = False;
        

    def printWelcome(self):
        wait = True;
        while(wait):
            if(self.ser.readline()):    #waits for the first newline character to be received and then discards it
                input_text = self.ser.readline().decode("ascii")
                print("\t\t\t\t\t Python Control LFSR", "    --   ", input_text)   #prints the welcome message
                self.ser.readline().decode("ascii")     #catches the newline characters after the welcome message
                self.ser.readline().decode("ascii")
                wait = False;


def main():
    seed = 0b1010110011100001       #ACE1 - the same seed as the hardware LFSR
    lfsr1 = lfsr(seed)
    

if __name__ == "__main__":      
    main()
