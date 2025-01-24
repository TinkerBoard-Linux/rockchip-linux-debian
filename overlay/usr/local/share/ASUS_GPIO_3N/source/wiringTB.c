#include "wiringTB.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>

#define CONFIG_I2S_SHORT

#define BLOCK_SIZE (64*1024)

//jason add for asuspi
static int  mem_fd;
static void* gpio_map0[5];
static volatile unsigned* gpio0[5];

static void *grf_map;
static volatile unsigned *grf;

static void *pwm_map;
static volatile unsigned *pwm;

static void *pmu_map;
static volatile unsigned *pmu;

static void *cru_map;
static volatile unsigned *cru;

/* Format Convert*/
int* asus_get_physToGpio(int rev)
{
        static int physToGpio_AP [64] =
        {
                -1,                                      // 0
                -1,                -1,                   //1, 2
                -1, 	           GPIO4_C2,                   //3, 4
                GPIO3_B1,          GPIO4_C3,                   //5, 6
                GPIO3_B2,          GPIO4_C4,             //7, 8
                GPIO3_B3,          GPIO4_C5,             //9, 10
                GPIO3_B4,          GPIO4_C6,             //11, 12
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1,  	           -1,                   //13, 14
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, //41-> 55
                -1, -1, -1, -1, -1, -1, -1, -1 // 56-> 63
        } ;
        return physToGpio_AP;
}
int* asus_get_pinToGpio(int rev)
{
        static int pinToGpio_AP [64] =
        {
                GPIO4_C2,          GPIO3_B1,        //0, 1
                GPIO4_C3,          GPIO3_B2,        //2, 3
                GPIO4_C4,          GPIO3_B3,        //4, 5
                GPIO4_C5,          GPIO3_B4,        //6, 7
                GPIO4_C6,          -1,        //8, 9
                -1,          -1,        //10, 11
                -1,          -1,        //12, 13
                -1,          -1,        //14, 15
                -1,          -1,              //16, 17
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1,                -1,              //18, 19
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // ... 47
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // ... 63
        } ;
        return pinToGpio_AP;
}

int pud_2_tb_format(int pud)
{
        switch(pud)
        {
                case PUD_OFF:
                        return 0b00;
                case PUD_DOWN:
                        return 0b10;
                case PUD_UP:
                        return 0b01;
                default:
                        return 0;
        }
}

int alt_2_tb_format(int alt)
{
        switch(alt)
        {
                case FSEL_INPT:
                case FSEL_OUTP:
                case FSEL_ALT0:
                        return 0;
                case FSEL_ALT1:
                        return 1;
                case FSEL_ALT2:
                        return 2;
                case FSEL_ALT3:
                        return 3;
                case FSEL_ALT4:
                        return 4;
                case FSEL_ALT5:
                        return 5;
                default:
                        return -1;
        }
}

/* Register Offset Table */
int GET_PULL_OFFSET(int bank, int pin)
{
        int PULL_TABLE [5][4] =
        {
                {          -1,           -1, 	       -1,           -1},        //Bank 0
                {          -1,           -1,           -1,           -1},        //Bank 1
                {-1, -1, -1,           -1},        //Bank 2
                {-1, GRF_GPIO3B_P, -1, -1},        //Bank 3
                {-1, -1, GRF_GPIO4C_P, -1},        //Bank 4
        } ;
        return PULL_TABLE[bank][(int)(pin / 8)];
}

// TODO: 改成3B和4C table分開
int GET_DRV_OFFSET(int bank, int pin)
{
	int grp = pin / 8;
        int DRV_TABLE_3B [4] = { GRF_GPIO3B_DS_0, GRF_GPIO3B_DS_1,  GRF_GPIO3B_DS_2,  GRF_GPIO3B_DS_3};        //Bank 3
        int DRV_TABLE_4C [4] = { GRF_GPIO4C_DS_0, GRF_GPIO4C_DS_1,  GRF_GPIO4C_DS_2,  GRF_GPIO4C_DS_3};        //Bank 3
      
	if( !((bank == 3 && grp == 1) || (bank == 4 && grp == 2))) return -1;

	if(bank == 3)
		return DRV_TABLE_3B[(pin % 8) / 2];
	else if (bank == 4)
		return DRV_TABLE_4C[(pin % 8) / 2];
}

/* common */
int gpioToBank(int gpio)
{
	/*
        if(gpio < 24)
                return 0;
        else
                return (int)((gpio - 24) / 32) + 1;
	*/
	return (int)(gpio / 32);
}

int gpioToBankPin(int gpio)
{
	/*
        if(gpio < 24)
                return gpio;
        else
                return (gpio - 24) % 32;
	*/
	return gpio % 32;
}

int tinker_board_setup(int rev)
{
        int i;
        if ((mem_fd = open("/dev/mem", O_RDWR|O_SYNC) ) < 0) 
        {
                if ((mem_fd = open ("/dev/gpiomem", O_RDWR | O_SYNC | O_CLOEXEC) ) < 0)
                {
                        printf("can't open /dev/mem and /dev/gpiomem\n");
                        printf("wiringPiSetup: Unable to open /dev/mem and /dev/gpiomem: %s\n", strerror (errno));
                        return -1;
                }
        }
        for(i=1;i<5;i++)
        {
                // mmap GPIO 

                #ifdef ANDROID
                gpio_map0[i] = mmap64(
                #else
                gpio_map0[i] = mmap(
                #endif
                        NULL,             // Any adddress in our space will do 
                        BLOCK_SIZE,       // Map length 
                        PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory 
                        MAP_SHARED,       // Shared with other processes 
                        mem_fd,           // File to map 
                        RK3568_GPIO(i)         //Offset to GPIO peripheral 
                );
                if (gpio_map0[i] == MAP_FAILED)
                {
                        printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                        return -1;
                }
                gpio0[i] = (volatile unsigned *)gpio_map0[i];

        }//for
        /////////////mmap grf////////////
        #ifdef ANDROID
        grf_map = mmap64(
        #else
        grf_map = mmap(
        #endif
                NULL,             // Any adddress in our space will do 
                BLOCK_SIZE,       // Map length 
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory 
                MAP_SHARED,       // Shared with other processes 
                mem_fd,           // File to map 
                RK3568_SYS_GRF         //Offset to GPIO peripheral 
        );
        if (grf_map  == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        grf = (volatile unsigned *)grf_map;
        ////////////////////////////  
        ////////////mmap pwm////////
        #ifdef ANDROID
        pwm_map = mmap64(
        #else
        pwm_map = mmap(
        #endif
                NULL,             // Any adddress in our space will do 
                BLOCK_SIZE,       // Map length 
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory 
                MAP_SHARED,       // Shared with other processes 
                mem_fd,           // File to map 
                RK3568_PWM         //Offset to GPIO peripheral 
        );
        if (pwm_map == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        pwm = (volatile unsigned *)pwm_map;
        ////////////////////////////
        ////////////mmap pmu//////////
        #ifdef ANDROID
        pmu_map = mmap64(
        #else
        pmu_map = mmap(
        #endif
                NULL,             // Any adddress in our space will do 
                BLOCK_SIZE,       // Map length 
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory 
                MAP_SHARED,       // Shared with other processes 
                mem_fd,           // File to map 
                RK3568_PMU         //Offset to GPIO peripheral 
        );
        if (pmu_map == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        pmu = (volatile unsigned *)pmu_map;
        ///////////////////////////////
        ////////////mmap cru//////////
        #ifdef ANDROID
        cru_map = mmap64(
        #else
        cru_map = mmap(
        #endif
                NULL,             // Any adddress in our space will do
                BLOCK_SIZE,       // Map length
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
                MAP_SHARED,       // Shared with other processes
                mem_fd,           // File to map
                RK3568_CRU         //Offset to GPIO peripheral
        );
        if (cru_map == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        cru = (volatile unsigned *)cru_map;
        ///////////////////////////////
        close(mem_fd); // No need to keep mem_fdcru open after mmap
        return 0;
}

int gpio_is_valid(int gpio)
{
        switch (gpio)
        {
                case GPIO3_B1:
                case GPIO3_B2:
                case GPIO3_B3:
                case GPIO3_B4:
                case GPIO4_C2:
                case GPIO4_C3:
                case GPIO4_C4:
                case GPIO4_C5:
                case GPIO4_C6:
                        return 1;
                default:
                        return 0;
        }
}

//  Tinker3N no CLK
/*
#if 0
int gpio_clk_disable(int gpio)
{
        int bank, bank_clk_en;
        int write_bit, reg_offset;
        bank = gpioToBank(gpio);
        write_bit = (bank != 0) ? bank : 4;
        reg_offset = (bank != 0) ? CRU_CLKGATE14_CON : CRU_CLKGATE17_CON;
        bank_clk_en = (*(cru+reg_offset/4) >> write_bit) & 0x1;
        *(cru+reg_offset/4) = (*(cru+reg_offset/4) & ~(0x1 << write_bit)) | (0x1 << (16 + write_bit));
        return bank_clk_en;
}

void gpio_clk_recovery(int gpio, int flag)
{
        int bank;
        int write_bit, reg_offset;
        bank = gpioToBank(gpio);
        write_bit = (bank != 0) ? bank : 4;
        reg_offset = (bank != 0) ? CRU_CLKGATE14_CON : CRU_CLKGATE17_CON;
        *(cru+reg_offset/4) = (*(cru+reg_offset/4) | (flag << write_bit)) | (0x1 << (16 + write_bit));
}
#else
void gpio_clk_enable(void)
{
        int write_bit, reg_offset;
        //bank = gpioToBank(gpio);
        for(int bank = 0 ; bank <= 8 ; bank++){
                write_bit = (bank != 0) ? bank : 4;
                reg_offset = (bank != 0) ? CRU_CLKGATE14_CON : CRU_CLKGATE17_CON;
                *(cru+reg_offset/4) = (*(cru+reg_offset/4) & ~(0x1 << write_bit)) | (0x1 << (16 + write_bit));
        }
}
#endif
*/

int asus_get_pin_mode(int pin)
{
        int value, func;
        int bank, bank_pin;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);
	int addr_SWPORT_DDR;

        switch(pin)
        {
                //GPIO3B
                case GPIO3_B1 :
                case GPIO3_B2 :
			value = *(grf+GRF_GPIO3B_IOMUX_L/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 4: func = SERIAL;	break;
				default: func = -1;
			}
			break;
                case GPIO3_B3 :
			value = *(grf+GRF_GPIO3B_IOMUX_L/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 4: func = I2C;	break;
				default: func = -1;
			}
			break;
		case GPIO3_B4 :
			value = *(grf+GRF_GPIO3B_IOMUX_H/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 4: func = I2C;	break;
				default: func = -1;
			}
			break;
                case GPIO4_C2 :
                case GPIO4_C3 :
			value = *(grf+GRF_GPIO4C_IOMUX_L/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 1: func = PWM;	break;
				case 2: func = SPI;	break;
				case 5: func = I2S;	break;
				default: func = -1;
			}
			break;
                case GPIO4_C4 :
			value = *(grf+GRF_GPIO3B_IOMUX_H/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 5: func = I2S;	break;
				default: func = -1;
			}
			break;
                case GPIO4_C5 :
                case GPIO4_C6 :
			value = *(grf+GRF_GPIO4C_IOMUX_H/4) & (0x07 << 4*(bank_pin % 4));
			switch(value)
			{
				case 0: func = GPIO; 	break;
				case 1: func = PWM;	break;
				case 2: func = SPI;	break;
				case 5: func = I2S;	break;
				default: func = -1;
			}
			break;
        }

	/*
        switch(pin)
        {
                //GPIO3B
                case GPIO3_B1 :
                case GPIO3_B2 :
                        value = ((*(grf+GRF_GPIO3B_IOMUX_L/4))>>((pin%8)*4)) & 0x00000003;
			switch(value)
			{
				case 0: func=GPIO;	break;
				case 4: func=SERIAL;	break;
				default: func=-1;	break;
			}
			break;
                case GPIO3_B3 :
                        value = ((*(grf+GRF_GPIO3B_IOMUX_L/4))>>((pin%8)*4)) & 0x00000007;
                        switch(value)
                        {
                                case 0: func=GPIO;            break;
                                case 4: func=I2C;              break;
                                default: func=-1;             break;
                        }
                        break;
                case GPIO3_B4 :
                        value = ((*(grf+GRF_GPIO3B_IOMUX_H/4))>>((pin%8)*4)) & 0x00000007;
                        switch(value)
                        {
                                case 0: func=GPIO;            break;
                                case 4: func=I2C;              break;
                                default: func=-1;             break;
                        }
                        break;
                case GPIO4_C2 :
                case GPIO4_C3 :
                        value = ((*(grf+GRF_GPIO4C_IOMUX_L/4))>>((pin%8)*4)) & 0x00000007;
                        switch(value)
                        {
                                case 0: func=GPIO;            break;
                                case 1: func=PWM;             break;
                                case 2: func=SPI;		break;
                                case 5: func=I2S;		break;
                                default: func=-1;             break;
                        }
						break;
                case GPIO4_C4 :
                        value = ((*(grf+GRF_GPIO4C_IOMUX_H/4))>>((pin%8)*4)) & 0x00000007;
                        switch(value)
                        {
                                case 0: func=GPIO;            break;
                                case 5: func=I2S;          break;
                                default: func=-1;             break;
                        }
						break;
                case GPIO4_C5 :
                case GPIO4_C6 :
                        value = ((*(grf+GRF_GPIO4C_IOMUX_H/4))>>((pin%8)*4)) & 0x00000007;
                        switch(value)
                        {
                                case 0: func=GPIO;            break;
                                case 1: func=PWM;             break;
                                case 2: func=SPI;              break;
                                case 4: func=SERIAL;          break;
                                case 5: func=I2S;          break;
                                default: func=-1;             break;
                        }
                        break;
        }
	*/

       if (func == GPIO)
       {
	       /*
                if (*(gpio0[bank]+GPIO_SWPORT_DDR_L/4) & (1<<bank_pin))
                        func = OUTPUT;
                else
                        func = INPUT;
		*/
	       if(bank_pin < 16)
	       {
		       addr_SWPORT_DDR = GPIO_SWPORT_DDR_L;
		       //GPIO_SWPORT_DDR_L
	       }
	       else
	       {
		       addr_SWPORT_DDR = GPIO_SWPORT_DDR_H;
		       //GPIO_SWPORT_DDR_H
	       }
		if(*(gpio0[bank] + addr_SWPORT_DDR/4) & (1 << (bank_pin%16)))
			func = OUTPUT;
		else
			func = INPUT;
        }
        printf("\nget_pin_mode: pin=%d, value=%x, func=%x\n",pin, value, func);
        return func;
}

void asus_set_pinmode_as_gpio(int pin)
{
		
        switch(pin)
        {
                case GPIO3_B1 :
                case GPIO3_B2 :
                case GPIO3_B3 :
                        *(grf+GRF_GPIO3B_IOMUX_L/4) = (0x07 << (4*(pin%4)+ 16));
			break;
                case GPIO3_B4 :
                        *(grf+GRF_GPIO3B_IOMUX_H/4) = (0x07 << (4*(pin%4)+ 16));
			break;
                case GPIO4_C2 :
                case GPIO4_C3 :
                        *(grf+GRF_GPIO4C_IOMUX_L/4) = (0x07 << (4*(pin%4)+ 16));
			break;
                case GPIO4_C4 :
                case GPIO4_C5 :
                case GPIO4_C6 :
                        *(grf+GRF_GPIO4C_IOMUX_H/4) = (0x07 << (4*(pin%4)+ 16));
                        break;
                default:
                        printf("wrong gpio\n");
                        break;
        }        //switch(pin)

}

void asus_set_pin_mode(int pin, int mode)
{
        int bank, bank_pin;
	unsigned int tmp, mask = 0x07;
	int addr_SWPORT_DDR;


        if(!gpio_is_valid(pin))
                return;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);



	if(bank_pin < 16)	addr_SWPORT_DDR = GPIO_SWPORT_DDR_L;
	else
	{		
		addr_SWPORT_DDR = GPIO_SWPORT_DDR_H;
		bank_pin %= 16;
	}
        
	if(INPUT == mode)
        {

                asus_set_pinmode_as_gpio(pin);
                *(gpio0[bank]+addr_SWPORT_DDR/4) = (0x1<< (bank_pin+16));
        }
        else if(OUTPUT == mode)
        {
                asus_set_pinmode_as_gpio(pin);
                *(gpio0[bank]+addr_SWPORT_DDR/4) = (0x10001<<bank_pin);
        } 
        else if(PWM_OUTPUT == mode)
        {
                //set pin PWMx to pwm mode
                if(pin == PWM12)
                {
			tmp = *(grf + GRF_GPIO4C_IOMUX_H);
		       	tmp = (tmp & (~mask << 4) | (0x01 << 4));
			*(grf + GRF_GPIO4C_IOMUX_H) = tmp;
                        //*(grf+GRF_GPIO7CH_IOMUX/4) =  (*(grf+GRF_GPIO7CH_IOMUX/4) | (0x0f<<(16+(pin%8-4)*4))) | (0x03<<((pin%8-4)*4));
                }
                else if(pin == PWM13)
                {
			tmp = *(grf + GRF_GPIO4C_IOMUX_H);
		       	tmp = (tmp & (~mask << 8) | (0x01 << 8));
			*(grf + GRF_GPIO4C_IOMUX_H) = tmp;
                        //*(grf+GRF_GPIO7CH_IOMUX/4) =  (*(grf+GRF_GPIO7CH_IOMUX/4) | (0x0f<<(16+(pin%8-4)*4))) | (0x03<<((pin%8-4)*4));
                }
		else if(pin == PWM14)
		{
			tmp = *(grf + GRF_GPIO4C_IOMUX_L);
		       	tmp = (tmp & (~mask << 8) | (0x01 << 8));
			*(grf + GRF_GPIO4C_IOMUX_L) = tmp;
		}
		else if(pin == PWM15)
		{
			tmp = *(grf + GRF_GPIO4C_IOMUX_L);
		       	tmp = (tmp & (~mask << 12) | (0x01 << 12));
			*(grf + GRF_GPIO4C_IOMUX_H) = tmp;
		}
                else
                {
                        printf("This pin cannot set as pwm out\n");
                }
        }
	// 3N no gpio clock
	/*
        else if(GPIO_CLOCK == mode)
        {
                if(pin == GPIO0_C1)
                {
                        *(pmu+PMU_GPIO0C_IOMUX/4) = (*(pmu+PMU_GPIO0C_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x01<<((pin%8)*2));
                }
                else
                        printf("This pin cannot set as gpio clock\n");
        }*/
}



void asus_digitalWrite(int pin, int value)
{
        int bank, bank_pin;
        int op=0;
	int dir_SWPORT_DDR, val_SWPORT_DR;
	unsigned int dir_tmp, val_tmp;
        volatile unsigned* addr;
        if(!gpio_is_valid(pin))
                return;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);

	if(bank_pin < 16)
        {
                dir_SWPORT_DDR = GPIO_SWPORT_DDR_L;
		val_SWPORT_DR = GPIO_SWPORT_DR_L;
                //GPIO_SWPORT_DDR_L
        }
        else
        {
                dir_SWPORT_DDR = GPIO_SWPORT_DDR_H;
		val_SWPORT_DR = GPIO_SWPORT_DR_H;
		bank_pin = bank_pin % 16;
                //GPIO_SWPORT_DDR_H
        }
	if (value == 1)
        	*(gpio0[bank]+val_SWPORT_DR/4) = (0x10001<<bank_pin);
	else
        	*(gpio0[bank]+val_SWPORT_DR/4) = (0x1<<(bank_pin+16));

	/*
	dir_tmp = *(volatile unsigned *)(gpio_map0[bank]+dir_SWPORT_DDR);
	dir_tmp |= (1<<bank_pin+16);
        *(volatile unsigned *)(gpio_map0[bank]+dir_SWPORT_DDR) = dir_tmp;
	dir_tmp |= (1<<bank_pin);
        *(volatile unsigned *)(gpio_map0[bank]+dir_SWPORT_DDR) = dir_tmp;
	
	val_tmp = *(volatile unsigned *)(gpio_map0[bank]+val_SWPORT_DR);
        if(value > 0)
        {
		val_tmp |= (1<<bank_pin+16);
                *(volatile unsigned *)(gpio_map0[bank]+val_SWPORT_DR) = val_tmp;
		val_tmp |= (1<<bank_pin);
                *(volatile unsigned *)(gpio_map0[bank]+val_SWPORT_DR) = val_tmp;
        }
        else
        {
		val_tmp |= (1<<bank_pin+16);
                *(volatile unsigned *)(gpio_map0[bank]+val_SWPORT_DR) = val_tmp;
		val_tmp &= ~(1 << bank_pin);
                *(volatile unsigned *)(gpio_map0[bank]+val_SWPORT_DR) = val_tmp;
        }
	*/
}


int asus_digitalRead(int pin)
{
        int value;
        int bank, bank_pin;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);

        value = (*(gpio0[bank]+GPIO_EXT_PORT/4) >> bank_pin) & 0x1;

        return value;
}

void asus_pullUpDnControl (int pin, int pud) {
    int bank, bank_pin;
    int GPIO_P_offset;
    int write_bit;
    unsigned int tmp;

    if (!gpio_is_valid(pin)) {
        printf("wrong gpio\n");
        return;
    }

    bank = gpioToBank(pin);
    bank_pin = gpioToBankPin(pin);
    GPIO_P_offset = GET_PULL_OFFSET(bank, bank_pin);
    if (GPIO_P_offset == -1) {
        printf("wrong offset\n");
        return;
    }

    pud = pud_2_tb_format(pud);

    *(grf+GPIO_P_offset/4) = ((0x3 << 16) + pud) << ((bank_pin % 8) / 2);
    /*
        if(bank == 0)
        {
                *(pmu+GPIO_P_offset/4) = (*(pmu+GPIO_P_offset/4) & ~(0x3 << write_bit)) | (pud << write_bit);        //without write_en
        }
        else
        {
                *(grf+GPIO_P_offset/4) = (0x3 << (16 + write_bit)) | (pud << write_bit);                             //with write_en
        }*/
    /*tmp = *(grf + GPIO_P_offset);
    tmp = (tmp & ~(0x03 << write_bit)) | (pud << write_bit);
    tmp = tmp | (0x01 << (16 + write_bit));
    *(grf + GPIO_P_offset) = tmp;*/
}


int asus_get_pwm_value(int pin)
{
        unsigned int range;
        unsigned int value;
        int PWM_PERIOD_OFFSET = -1;
        int PWM_DUTY_OFFSET = -1;
        switch (pin)
        {
                case PWM12:
                case PWM13:
                case PWM14:
                case PWM15:
                        PWM_PERIOD_OFFSET=RK3568_PWM3_PERIOD;
                        PWM_DUTY_OFFSET=RK3568_PWM3_DUTY;
                        break;
                default:
                        break;
        }
        if(asus_get_pin_mode(pin)==PWM && PWM_PERIOD_OFFSET != -1 && PWM_DUTY_OFFSET != -1)
        {
                range = *(pwm+PWM_PERIOD_OFFSET);        //Get period
                value = range - *(pwm+PWM_DUTY_OFFSET); //Get duty
                return value;
        }
        else
        {
                return -1;
        }
}

void asus_set_pwmPeriod(int pin, unsigned int period)
{
        int pwm_value;
        int PWM_CTRL_OFFSET = -1;
        int PWM_PERIOD_OFFSET = -1;
        switch (pin)
        {
                case PWM12:
                case PWM13:
                case PWM14:
                case PWM15:
                        PWM_PERIOD_OFFSET=RK3568_PWM3_PERIOD;
                        PWM_CTRL_OFFSET=RK3568_PWM3_CTR;
                        break;
                default:
                        break;
        }
        if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1 && PWM_PERIOD_OFFSET != -1)
        {
                pwm_value = asus_get_pwm_value(pin);
                *(pwm+PWM_CTRL_OFFSET) &= ~(1<<0);        //Disable PWM
                *(pwm+PWM_PERIOD_OFFSET) = period;        //Set period PWM
                *(pwm+PWM_CTRL_OFFSET) |= (1<<0);         //Enable PWM
                if(pwm_value != -1)
                        asus_pwm_write(pin, pwm_value);
        }
}

void asus_set_pwmRange(unsigned int range)
{
        asus_set_pwmPeriod(PWM12, range);
        asus_set_pwmPeriod(PWM13, range);
        asus_set_pwmPeriod(PWM14, range);
        asus_set_pwmPeriod(PWM15, range);
}

void asus_set_pwmFrequency(int pin, int divisor)
{
        int PWM_CTRL_OFFSET = -1;
        switch (pin)
        {
                case PWM12:
                case PWM13:
                case PWM14:
                case PWM15:
                        PWM_CTRL_OFFSET=RK3568_PWM3_CTR;
                        break;
                default:
                        break;
        }
        if (divisor > 0xff)
                divisor = 0x100;
        else if(divisor < 2)
                divisor = 0x02;
        if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1)
        {
                *(pwm+PWM_CTRL_OFFSET) &= ~(1<<0);        //Disable PWM
                *(pwm+PWM_CTRL_OFFSET) = (*(pwm+PWM_CTRL_OFFSET) & ~(0xff << 16)) | ((0xff & (divisor/2)) << 16) | (1<<9) ;        //PWM div
                *(pwm+PWM_CTRL_OFFSET) |= (1<<0); //Enable PWM
        }
}


void asus_set_pwmClock(int divisor)
{
        asus_set_pwmFrequency(PWM12, divisor);
        asus_set_pwmFrequency(PWM13, divisor);
        asus_set_pwmFrequency(PWM14, divisor);
        asus_set_pwmFrequency(PWM15, divisor);
}

void asus_pwm_write(int pin, int value)
{
        int mode = 0;
        unsigned int range;
        int PWM_CTRL_OFFSET = -1;
        int PWM_PERIOD_OFFSET = -1;
        int PWM_DUTY_OFFSET = -1;
        switch (pin)
        {
                case PWM12:
                case PWM13:
                case PWM14:
                case PWM15:
                        PWM_PERIOD_OFFSET=RK3568_PWM3_PERIOD;
                        PWM_DUTY_OFFSET=RK3568_PWM3_DUTY;
                        PWM_CTRL_OFFSET=RK3568_PWM3_CTR;
                        break;
                default:
                        break;
        }
        if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1 && PWM_PERIOD_OFFSET != -1 && PWM_DUTY_OFFSET != -1)
        {
                range = *(pwm+PWM_PERIOD_OFFSET);
                *(pwm+PWM_CTRL_OFFSET) &= ~(1<<0);        //Disable PWM
                *(pwm+PWM_DUTY_OFFSET) = range - value; //Set duty
                if(mode == CENTERPWM)
                {
                        *(pwm+PWM_CTRL_OFFSET) |= (1<<5);
                }
                else
                {
                        *(pwm+PWM_CTRL_OFFSET) &= ~(1<<5);
                }
                *(pwm+PWM_CTRL_OFFSET) |= (1<<1); // PWM continuous mode: 2b01
                *(pwm+PWM_CTRL_OFFSET) &= ~(1<<2);
                *(pwm+PWM_CTRL_OFFSET) |= (1<<4);
                *(pwm+PWM_CTRL_OFFSET) |= (1<<0); //Enable PWM
        }
        else
        {
                printf("please set this pin to pwmmode first\n");
        }
}

void asus_pwmToneWrite(int pin, int freq)
{
        int divi, pwm_clock, range;
        switch (pin)
        {
                case PWM12:
                case PWM13:
                case PWM14:
                case PWM15:
			divi=((*(pwm+RK3568_PWM3_CTR) >> 16) & 0xff) << 1; 
			break;
                default:
			divi=-1;
			break;
        }

	// TODO: not sure
        if(divi == 0)
                divi = 512;
        if (freq == 0)
                asus_pwm_write (pin, 0) ;
        else
        {
                pwm_clock = 74250000 / divi;                //74.25Mhz / divi
                range = pwm_clock / freq ;
                asus_set_pwmPeriod (pin, range) ;
                asus_pwm_write (pin, range / 2) ;
        }
}


// 
/*
void asus_set_gpioClockFreq(int pin, int freq)
{
        int divi;
        if(pin != GPIO0_C1)
        {
                printf("This pin cannot set as gpio clock\n");
                return;
        }
        divi = 297000000 / freq - 1;
        if (divi > 31)
                divi = 31 ;
        else if(divi < 0)
                divi = 0;
        *(cru+CRU_CLKSEL2_CON/4) = (*(cru+CRU_CLKSEL2_CON/4) & (~(0x1F<<8))) | 0x1f << (8+16) | (divi<<8);
}
*/

// 
int asus_get_pinAlt(int pin)
{
        int alt;
        int bank, bank_pin;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);
        switch(pin)
        {
                //GPIO3B
                case GPIO3_B1 :
                case GPIO3_B2 :
                case GPIO3_B3 :
                        alt = ((*(grf+GRF_GPIO3B_IOMUX_L))>>((pin%8)*4)) & 0x00000007;
                        break;
                case GPIO3_B4 :
                        alt = ((*(grf+GRF_GPIO3B_IOMUX_H))>>((pin%8)*4)) & 0x00000007;
                        break;

                //GPIO4C
                case GPIO4_C2 :
                case GPIO4_C3 :
                        alt = ((*(grf+GRF_GPIO4C_IOMUX_L))>>((pin%8)*4)) & 0x00000007;
                        break;
                case GPIO4_C4 :
                case GPIO4_C5 :
                case GPIO4_C6 :
                        alt = ((*(grf+GRF_GPIO4C_IOMUX_H))>>((pin%8)*4)) & 0x00000007;
                        break;
                default:
                        alt=-1;
                        break;
        }

        //RPi alt ("   GPIO  "), "ALT0", "ALT1", "ALT2", "ALT3", "ALT4", "ALT5"
        //          0      1        2      3        4      5       6       7
        //RPi alt ("IN", "OUT"), "ALT5", "ALT4", "ALT0", "ALT1", "ALT2", "ALT3"
        int alts[7] = {0, FSEL_ALT0, FSEL_ALT1, FSEL_ALT2, FSEL_ALT3, FSEL_ALT4, FSEL_ALT5};
        if(alt < 7)
        {
                alt = alts[alt];
        }

    if (alt == 0)
    {
	    if (bank_pin < 16)
                if (*(gpio0[bank]+GPIO_SWPORT_DDR_L) & (1<<bank_pin))
                        alt = FSEL_OUTP;
                else
                        alt = FSEL_INPT;
	    else

                if (*(gpio0[bank]+GPIO_SWPORT_DDR_H) & (1<<(bank_pin - 16)))
                        alt = FSEL_OUTP;
                else
                        alt = FSEL_INPT;
    }
        return alt;
}

void SetGpioMode(int pin, int alt)
{
        alt = ~alt & 0x3;
        switch(pin)
        {
                //GPIO3B
                case GPIO3_B1 :
                case GPIO3_B2 :
                case GPIO3_B3 :
                        *(grf+GRF_GPIO3B_IOMUX_L) = (*(grf+GRF_GPIO3B_IOMUX_L) | (0x07<<((pin%8)*4+16)) | (0x7 << ((pin % 8)*4))) & (~(alt<<((pin%8)*4)));
                        break;
                case GPIO3_B4 :
                        *(grf+GRF_GPIO3B_IOMUX_H) = (*(grf+GRF_GPIO3B_IOMUX_H) | (0x07<<((pin%8)*4+16)) | (0x7 << ((pin % 8)*4))) & (~(alt<<((pin%8)*4)));
                        break;

                //GPIO4C
                case GPIO4_C2 :
                case GPIO4_C3 :
                        *(grf+GRF_GPIO4C_IOMUX_L) =  (*(grf+GRF_GPIO4C_IOMUX_L) | (0x07<<((pin%8)*4+16)) | (0x7 << ((pin % 8)*4))) & (~(alt<<((pin%8)*4)));
                        break;
                case GPIO4_C4 :
                case GPIO4_C5 :
                case GPIO4_C6 :
                        *(grf+GRF_GPIO4C_IOMUX_H) =  (*(grf+GRF_GPIO4C_IOMUX_H) | (0x07<<((pin%8)*4+16)) | (0x7 << ((pin % 8)*4))) & (~(alt<<((pin%8)*4)));
                        break;

                default:
                        printf("wrong gpio\n");
                        break;
        }
}

void asus_set_pinAlt(int pin, int alt)
{
        int bank, bank_pin;
        int tb_format_alt;
        if(!gpio_is_valid(pin))
                return;
        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);
        tb_format_alt = alt_2_tb_format(alt);
        if(tb_format_alt == -1)
        {
                printf("wrong alt\n");
                return;
        }
        SetGpioMode(pin, tb_format_alt);
	
	if(bank_pin < 16)
        	if(alt == FSEL_INPT)
			*(gpio0[bank]+GPIO_SWPORT_DDR_L) &= ~(1<<bank_pin);
	        else if(alt == FSEL_OUTP)
        	        *(gpio0[bank]+GPIO_SWPORT_DDR_L) |= (1<<bank_pin);
	else
        	if(alt == FSEL_INPT)
			*(gpio0[bank]+GPIO_SWPORT_DDR_H) &= ~(1<<bank_pin);
	        else if(alt == FSEL_OUTP)
        	        *(gpio0[bank]+GPIO_SWPORT_DDR_H) |= (1<<bank_pin);
}


/* drv_type:
 * 6'000000: disable (-1)
 * 6'000001: lv0
 * 6'000011: lv1
 * 6'000111: lv2
 * 6'001111: lv3
 * 6'011111: lv4
 * 6'111111: lv5
 */

void asus_set_GpioDriveStrength(int pin, int drv_type)
{
        int bank, bank_pin;
        int GPIO_E_offset;
        //int write_en = 0x3f;
	int value;

        if(!gpio_is_valid(pin))
        {
                printf("wrong gpio\n");
                return;
        }
	if(drv_type < 0 || drv_type > 6)
	{
		printf("wrong driver strength type\n");
		return;
	}

        bank = gpioToBank(pin);
        bank_pin = gpioToBankPin(pin);

	value = 1 << (drv_type + 1) - 1;

        GPIO_E_offset = GET_DRV_OFFSET(bank, bank_pin);
        if(GPIO_E_offset == -1)
        {
                printf("wrong offset\n");
                return;
        }

	*(grf + GPIO_E_offset/4) = (0x3f << ((bank_pin % 2) * 8 + 16)) 
				+ (value << ((bank_pin % 2) * 8));

	/*	
	drv_type = 1 << (drv_type + 1) - 1;
	tmp = *(grf + GPIO_E_offset);
	tmp = tmp | (drv_type << ((bank_pin % 2)*8 + 16)) | (drv_type << ((bank_pin % 2)*8));
	*(grf + GPIO_E_offset) = tmp;
	*/
	/*
        write_bit = (bank_pin % 8) << 1;
        drv_type &= 0x3;
        if(bank == 0)
        {
                *(pmu+GPIO_E_offset/4) = (*(pmu+GPIO_E_offset/4) & ~(0x3 << write_bit)) | (drv_type << write_bit);        //without write_en
        }
        else
        {
                *(grf+GPIO_E_offset/4) = (0x3 << (16 + write_bit)) | (drv_type << write_bit);                             //with write_en
        }*/
}

int asus_get_GpioDriveStrength(int pin)
{
        int bank, bank_pin;
        int GPIO_E_offset;
        int write_bit;
        volatile unsigned *reg;

	int value, drv_type = -1;

        if(!gpio_is_valid(pin))
        {
                printf("wrong gpio\n");
                return -1;
        }
        bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
        GPIO_E_offset = GET_DRV_OFFSET(bank, bank_pin);
        if(GPIO_E_offset == -1)
        {
                printf("wrong offset\n");
                return -1;
        }

	value =	0x3f & (*(grf + GPIO_E_offset / 4) >> ((bank_pin % 2) * 8)) + 1;

	while(value >>= 1)
	{
		drv_type++;
	}


	return drv_type;
	//return (*(grf + GPIO_E_offset) >> (bank_pin % 2)*8) & 0x3f;
	/*
        write_bit = (bank_pin % 8) << 1;
        return (*(reg+GPIO_E_offset/4) >> write_bit) & 0x3;*/
}

void asus_cleanup(void)
{
        int i;
        for(i=0;i<GPIO_BANK;i++)
        {
            munmap((caddr_t)gpio_map0[i], BLOCK_SIZE);
        }
        munmap((caddr_t)grf_map, BLOCK_SIZE);
        munmap((caddr_t)pwm_map, BLOCK_SIZE);
        munmap((caddr_t)pmu_map, BLOCK_SIZE);
        munmap((caddr_t)cru_map, BLOCK_SIZE);
}

