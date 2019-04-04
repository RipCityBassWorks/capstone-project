
/*Include Statements*/
#include "PmodSD.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include <string>
#include <stdint.h>
/********************/
/*Define Statements**/
#define LFSR_ID XPAR_LFSR_IFACE_DEVICE_ID
#define MEM_A_ID XPAR_MEM_DATA_DEVICE_ID
#define MEM_B_ID XPAR_MEM_ADDR_DEVICE_ID
#define LFSR_EN 1
#define LFSR_DATA 2
#define MEM_ADDR 1
#define MEM_EN 2
#define MEM_DATA_IN 1
#define MEM_DATA_OUT 2
#define OUT 0
#define IN 1
//Constants
#define DATA_GOOD 0xFFFFFFFF
#define ADDR_SPACE 2000
#define TIME 1000

/********************/
/*Device Definitions*/
XGpio LFSR_D;
XGpio MEM_A;
XGpio MEM_B;
/********************/
/*Function Decleration*/
int main(void);
void DemoInitialize();
void SD(int32_t rando, int addr, int bit, int pc);
void LFSR_runtime();
void MEM_SCANNER();
int HW();
void timer_short();
int32_t printprep(int32_t data);
/********************/
/*Global Variable Declerations*/
int addr = 0;
uint32_t polled;
int bad_addr;
int bit_status;
int hw_init= 0; //hw initialization flag, when set system shouldn't run the initializitaion protocol more than once
int print_count; //for debugging printer
int lfsr_init = 0;
bool first_run = true;
int integer = 0;
u32 str_track = 0;
int32_t input;
int32_t storage;

FRESULT fr;
u32 bytesWritten = 0;
u32 bytesRead, totalBytesRead;
u8 buff[12], *buffptr;

DXSPISDVOL disk0(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR,
			         XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);


/********************/
/*Function Definintions*/

int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();
   if(hw_init == 0){
   HW();
   }
   //run forever
   while(1){
	 printprep(integer);
	 integer = integer + 1;

	 //LFSR_runtime();

   }


};

int32_t printprep(int32_t data){
	//A process to print the lfsr data, memory address and bit status
	SD(data, addr, bit_status, print_count);
	//SD(data, addr, bit_status, print_count, disk0);
	//SD(data, addr, bit_status, print_count, disk0);

	return 0;
}



void LFSR_runtime(){

	//Before entering the loop we need to store an initial value from the LFSR
	if(lfsr_init == 0){
	storage = XGpio_DiscreteRead(&LFSR_D, LFSR_DATA);
	lfsr_init = 1;
	}
	//The LFSR will need to run always, no matter what.

		//The LFSR doesn't run at system clock, so it won't always have new data.
		//We poll the line and store it, then compare against the last new value.
		input = XGpio_DiscreteRead(&LFSR_D, LFSR_DATA);
		//Then compare against stored, if they're the same do nothing,
		//if they're different, update the stored value and pass to printer
		if(input != storage){
			storage = input;
			//pass to printer
			print_count = print_count + 1;
			printprep(storage);
		}


}

void MEM_SCANNER(){
	//make sure variables are cleared
	int loc_ad;
	u32 pull = DATA_GOOD;
	//the memory scanner also runs forever,
		if(addr == 0){ //intentionally store bad data to memory to test the trigger function
			XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, 100); //write addr 100 to the memory system
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//set the write flag high to write data
			XGpio_DiscreteWrite(&MEM_A, MEM_DATA_OUT, 0);//write zero to the word
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);
			pull = XGpio_DiscreteRead(&MEM_A, MEM_DATA_IN);

			pull = DATA_GOOD;
			XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, 500); //write addr 200 to the memory system
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//set the write flag high to write data
			XGpio_DiscreteWrite(&MEM_A, MEM_DATA_OUT, 0);//write zero to the word
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);
			pull = XGpio_DiscreteRead(&MEM_A, MEM_DATA_IN);

			pull = DATA_GOOD;
			XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, 1500); //write addr 300 to the memory system
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//set the write flag high to write data
			XGpio_DiscreteWrite(&MEM_A, MEM_DATA_OUT, 0);//write zero to the word
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);
			pull = XGpio_DiscreteRead(&MEM_A, MEM_DATA_IN);

			pull = DATA_GOOD;
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);//clear the write flag

		}
		//first check if the address space has been exceeded
		if(addr >= ADDR_SPACE){
			addr = 0;
		}
		//Pass address to memory
		XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, addr);
		//Set write flag to 0 to read memory at the address
		XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);
		//Then read the memory into local variable for comparison
		polled = XGpio_DiscreteRead(&MEM_A, MEM_DATA_IN);
		loc_ad = addr;
		//Then compare the data to the
		if(polled != DATA_GOOD){
			//data corruption has occurred, store the address and set LFSR enable line high
			bad_addr = addr;
			bit_status = 1;
 			XGpio_DiscreteWrite(&LFSR_D, LFSR_EN, 1);
			//allow for enough time for the LFSR to be modified
			timer_short();
			XGpio_DiscreteWrite(&LFSR_D, LFSR_EN, 0);
			//now to reset the memory that has been corrupted. Since we have a known good value we pass it to the memory system
			XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, addr);//Rewrite address
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//Set the write line high
			XGpio_DiscreteWrite(&MEM_A, MEM_DATA_OUT, DATA_GOOD);//write known good data to corrupted word
			XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);//clear the write line, process complete
			addr = addr + 1; //after operation increment address
		}
		else{
			//if the data word at the address is good, we increment the address
			addr = addr + 1;
		}

}
int HW(){
	int LFSR_STATUS;
	int MEM_A_STATUS;
	int MEM_B_STATUS;
	int ad = 0;
	uint32_t good = DATA_GOOD;
	uint32_t dat;
	uint32_t str;
	LFSR_STATUS = XGpio_Initialize(&LFSR_D, LFSR_ID);
	MEM_A_STATUS = XGpio_Initialize(&MEM_A, MEM_A_ID);
	MEM_B_STATUS = XGpio_Initialize(&MEM_B, MEM_B_ID);
	//Initialize GPIO Blocks. If any initialization fails then return a failure error.
	if(LFSR_STATUS != XST_SUCCESS || MEM_A_STATUS != XST_SUCCESS || MEM_B_STATUS != XST_SUCCESS){
		xil_printf("GPIO INITIALIZATIN FAILED\r\n");
		return XST_FAILURE;
	}
	//If initialization is successful then set data directions
	//The LFSR Interface
	XGpio_SetDataDirection(&LFSR_D, LFSR_EN, OUT);
	XGpio_SetDataDirection(&LFSR_D, LFSR_DATA, IN);
	//The Memory Data Interface
	XGpio_SetDataDirection(&MEM_A, MEM_DATA_IN, IN);
	XGpio_SetDataDirection(&MEM_A, MEM_DATA_OUT, OUT);
	//The Memory Addressing Interface
	XGpio_SetDataDirection(&MEM_B, MEM_ADDR, OUT);
	XGpio_SetDataDirection(&MEM_B, MEM_EN, OUT);
	//set the initialization flag
	hw_init = 1;
	addr = 0;
	//loop to initialize the memory
	dat = 0;

	while(addr <= ADDR_SPACE){
		XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//Set the write line high
		XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, addr);//Rewrite address
		XGpio_DiscreteWrite(&MEM_A, MEM_DATA_OUT, DATA_GOOD);//write known good data to corrupted word
		//XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);//clear the write line, process complete

		addr = addr + 1; //after operation increment address
	}
		addr = 0;
	while(addr <= ADDR_SPACE){
				ad = addr;
				XGpio_DiscreteWrite(&MEM_B, MEM_EN, 1);//Set the write line high
				XGpio_DiscreteWrite(&MEM_B, MEM_ADDR, addr);//Rewrite address
				XGpio_DiscreteWrite(&MEM_B, MEM_EN, 0);
				dat = XGpio_DiscreteRead(&MEM_A, MEM_DATA_IN);
				str = dat;
				//printprep(dat);
				addr = addr + 1;
	}
}
void SD(int32_t rando, int addr, int bit, int pc) {

		DXSPISDVOL disk = disk0;
		DFILE file;
		DFILE file2;
			int eof;
			char printline[128];
			sprintf(printline, "\nLFSR: %d ADDR: %d", rando, addr);
			int str_size = strlen(printline);
			// The drive to mount the SD volume to.
			// Options are: "0:", "1:", "2:", "3:", "4:"
			static const char szDriveNbr[] = "0:";
			str_track = str_track + str_size;
			bytesWritten = bytesWritten + str_size;
			int bites = str_size;
			u32 bitbit;
			u8 buff[4], *buffptr;
			// Mount the disk
			DFATFS::fsmount(disk, szDriveNbr, 1);

			xil_printf("Disk mounted\r\n");
			//check if we need to poll the pointer
			//not sure if this is working properly
			if(first_run == true) {
				fr = file2.fsopen("pointer.txt", FA_READ);
				if (fr == FR_OK) {
				      buffptr = buff;
				      totalBytesRead = 0;
				      do {
				         fr = file2.fsread(buffptr, 1, &bytesRead);
				         buffptr++;
				         totalBytesRead += bytesRead;
				      } while (totalBytesRead < 4 && fr == FR_OK);

				      if (fr == FR_OK) {
				         xil_printf("Read successful:");
				         buff[totalBytesRead] = 0;
				         str_track = int(buff);
				         xil_printf("'%s'\r\n", buff);
				      } else {
				         xil_printf("Read failed\r\n");
				      }
				   } else {
				      xil_printf("Failed to open file to read from\r\n");
				   }
				first_run = false;
			}

			fr = file.fsopen("output.txt", FA_WRITE | FA_OPEN_ALWAYS);

			if (fr == FR_OK) {
				file.fslseek(str_track);
				file.fswrite(printline, str_size, &bytesWritten);
				file.flush();
				fr = file.fsclose();

			} else {
				xil_printf("Failed to open file to write to\r\n");
				}
			fr = file2.fsopen("pointer.txt", FA_WRITE | FA_OPEN_ALWAYS);

						if (fr == FR_OK) {
							file2.fswrite(printline, str_size, &bytesWritten);
							file2.flush();
							fr = file2.fsclose();

						} else {
							xil_printf("Failed to open file to write to\r\n");
							}

}
void timer_short(){
	int time = 0;
	while(time < TIME){
		time =+ 1;
	}

}