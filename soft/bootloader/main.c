/******************************************************************************
 *
 * Bootloader for soc-lm32
 *
 ******************************************************************************/

#include "stdio.h" 
#include "system.h" 

/* prototypes */
void writeint(uint8_t nibbles, uint32_t val);
uint32_t readint(uint8_t nibbles);

#define USAGE  "USAGE:\r\n"\
               "\th : help\r\n"\
               "\tu : Upload program\r\n"\
               "\t    8 digit hex start @\r\n"\
               "\t    8 digit hex size \r\n"\
               "\tv : view memory \r\n"\
               "\t    8 digit hex start @\r\n"\
               "\t    8 digit hex size \r\n"\
               "\tg : go to address\r\n"\
               "\te : echo\r\n"



// reads hex from uart and convert it to
// int. nibbles is the number of char to 
// read.
uint32_t readint(uint8_t nibbles)
{
    uint32_t val = 0, i;
    uint8_t c;
    for (i = 0; i < nibbles; i++) {
        val <<= 4;
        c = getchar();
        // putchar(c);
        if (c <= '9')
            val |= (c - '0') & 0xf;
        else
            val |= (c - 'A' + 0xa) & 0xf; 
    }

    return val;
}

// Writes to uart an unsigned int value as an hex
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
            if (digit >= 0xA) 
                putchar('A'+digit-10);
            else
                putchar('0'+digit);
        }
        val <<= 4;
    }
}

// Goto to address
void jump(unsigned int add) 
{
    printf ("Jumping to 0x%08x\r\n",add);
    asm volatile("b %0"::"r"(add));
}

// main loop
int main(int argc, char **argv)
{
    int8_t *p;
    int32_t *p32;

    printf("\r\n\r\n** TPT LM32 BOOTLOADER **");
    printf    ("\r\n** CFG REG %08x        **",get_cfg());
    for(;;) {
        uint32_t start, size, help;
        printf("\r\n>");
        uint8_t c = getchar();

        switch (c) {
            case 'h': // help
                printf( USAGE );
                break;
            case 'r': // reset
                jump(0x00000000);
                break;
            case 'u': // Upload programm
                /* read start address */
                start = readint(8);
                /* read program size */
                size = readint(8);
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
                    *p = readint(2);
                }
                break;
            case 'g': // go
                start = readint(8);
                jump(start);
                break; 
            case 'v': // view memory 
                //putchar('@'); 
                /* read start address */
                start = readint(8);
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
                    if (!(help++ & 3)) {
                        printf("\r\n[");
                        writeint(8, (uint32_t) p32);
                        putchar(']'); 
                    }
                    putchar(' '); 
                    writeint(8, *p32);
                }
                break;
            case 'e': // echo test
                while (1) {
                    putchar(getchar());
                }
                break;
        }
    }
}

