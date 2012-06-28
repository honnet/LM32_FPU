
main.o:     file format elf32-lm32

Disassembly of section .text:

00000000 <readint>:

// reads hex from uart and convert it to
// int. nibbles is the number of char to 
// read.
uint32_t readint(uint8_t nibbles)
{
   0:	20 27 00 ff 	andi r7,r1,0xff
    uint32_t val = 0, i;
    uint8_t c;
    for (i = 0; i < nibbles; i++) {
   4:	b8 e0 08 00 	mv r1,r7
   8:	44 e0 00 17 	be r7,r0,64 <readint+0x64>
   c:	34 01 00 00 	mvi r1,0
  10:	78 04 f0 00 	mvhi r4,0xf000
  14:	78 08 f0 00 	mvhi r8,0xf000
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
  18:	38 84 00 03 	ori r4,r4,0x3

    int x = UART_DATA;
  1c:	39 08 00 07 	ori r8,r8,0x7
  20:	b8 20 30 00 	mv r6,r1
        val <<= 4;
  24:	3c 25 00 04 	sli r5,r1,4
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
  28:	40 81 00 00 	lbu r1,(r4+0)
  2c:	20 21 00 01 	andi r1,r1,0x1
  30:	64 21 00 00 	cmpei r1,r1,0
  34:	5c 20 ff fd 	bne r1,r0,28 <readint+0x28>

    int x = UART_DATA;
  38:	41 01 00 00 	lbu r1,(r8+0)
  3c:	20 23 00 ff 	andi r3,r1,0xff
        c = getchar();
        // putchar(c);
        if (c <= '9')
  40:	74 62 00 39 	cmpgui r2,r3,0x39
            val |= (c - '0') & 0xf;
  44:	20 61 00 0f 	andi r1,r3,0xf
  48:	b8 a1 08 00 	or r1,r5,r1
    uint8_t c;
    for (i = 0; i < nibbles; i++) {
        val <<= 4;
        c = getchar();
        // putchar(c);
        if (c <= '9')
  4c:	44 40 00 04 	be r2,r0,5c <readint+0x5c>
            val |= (c - '0') & 0xf;
        else
            val |= (c - 'A' + 0xa) & 0xf; 
  50:	34 61 ff c9 	addi r1,r3,-55
  54:	20 21 00 0f 	andi r1,r1,0xf
  58:	b8 a1 08 00 	or r1,r5,r1
// read.
uint32_t readint(uint8_t nibbles)
{
    uint32_t val = 0, i;
    uint8_t c;
    for (i = 0; i < nibbles; i++) {
  5c:	34 c6 00 01 	addi r6,r6,1
  60:	5c e6 ff f1 	bne r7,r6,24 <readint+0x24>
        else
            val |= (c - 'A' + 0xa) & 0xf; 
    }

    return val;
}
  64:	c3 a0 00 00 	ret

00000068 <writeint>:

// Writes to uart an unsigned int value as an hex
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
  68:	20 21 00 ff 	andi r1,r1,0xff
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
  6c:	78 08 f0 00 	mvhi r8,0xf000
  70:	78 05 f0 00 	mvhi r5,0xf000
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);

    UART_DATA = (char) x;
  74:	78 07 f0 00 	mvhi r7,0xf000
}

// Writes to uart an unsigned int value as an hex
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
  78:	34 03 00 08 	mvi r3,8
  7c:	c8 61 18 00 	sub r3,r3,r1
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
  80:	39 08 00 00 	ori r8,r8,0x0
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
  84:	38 a5 00 03 	ori r5,r5,0x3

    UART_DATA = (char) x;
  88:	38 e7 00 07 	ori r7,r7,0x7
}

// Writes to uart an unsigned int value as an hex
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
  8c:	34 04 00 00 	mvi r4,0
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
            if (digit >= 0xA) 
  90:	34 09 00 09 	mvi r9,9
void writeint(uint8_t nibbles, uint32_t val)
{
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
  94:	54 64 00 0b 	bgu r3,r4,c0 <writeint+0x58>
            digit = (val & 0xf0000000) >> 28;
  98:	a0 48 08 00 	and r1,r2,r8
  9c:	00 21 00 1c 	srui r1,r1,28
            if (digit >= 0xA) 
                putchar('A'+digit-10);
            else
                putchar('0'+digit);
  a0:	34 26 00 30 	addi r6,r1,48
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
            if (digit >= 0xA) 
  a4:	51 21 00 0c 	bgeu r9,r1,d4 <writeint+0x6c>
                putchar('A'+digit-10);
  a8:	34 26 00 37 	addi r6,r1,55
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
  ac:	40 a1 00 00 	lbu r1,(r5+0)
  b0:	20 21 00 10 	andi r1,r1,0x10
  b4:	5c 20 ff fe 	bne r1,r0,ac <writeint+0x44>

    UART_DATA = (char) x;
  b8:	20 c1 00 ff 	andi r1,r6,0xff
  bc:	30 e1 00 00 	sb (r7+0),r1
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
    uint32_t i, digit;

    for (i=0; i<8; i++) {
  c0:	34 84 00 01 	addi r4,r4,1
  c4:	64 81 00 08 	cmpei r1,r4,8
  c8:	5c 20 00 0a 	bne r1,r0,f0 <writeint+0x88>
            if (digit >= 0xA) 
                putchar('A'+digit-10);
            else
                putchar('0'+digit);
        }
        val <<= 4;
  cc:	3c 42 00 04 	sli r2,r2,4
  d0:	e3 ff ff f1 	bi 94 <writeint+0x2c>
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
  d4:	40 a1 00 00 	lbu r1,(r5+0)
  d8:	20 21 00 10 	andi r1,r1,0x10
  dc:	44 20 ff f7 	be r1,r0,b8 <writeint+0x50>
  e0:	40 a1 00 00 	lbu r1,(r5+0)
  e4:	20 21 00 10 	andi r1,r1,0x10
  e8:	5c 20 ff fb 	bne r1,r0,d4 <writeint+0x6c>
  ec:	e3 ff ff f3 	bi b8 <writeint+0x50>
  f0:	c3 a0 00 00 	ret

000000f4 <jump>:
    }
}

// Goto to address
void jump(unsigned int add) 
{
  f4:	37 9c ff f8 	addi sp,sp,-8
  f8:	5b 8b 00 08 	sw (sp+8),r11
  fc:	5b 9d 00 04 	sw (sp+4),ra
 100:	b8 20 58 00 	mv r11,r1
    printf ("Jumping to 0x%08x\r\n",add);
 104:	78 01 00 00 	mvhi r1,0x0
 108:	b9 60 10 00 	mv r2,r11
 10c:	38 21 00 00 	ori r1,r1,0x0
 110:	f8 00 00 00 	calli 110 <jump+0x1c>
    asm volatile("b %0"::"r"(add));
 114:	c1 60 00 00 	b r11
}
 118:	2b 8b 00 08 	lw r11,(sp+8)
 11c:	2b 9d 00 04 	lw ra,(sp+4)
 120:	37 9c 00 08 	addi sp,sp,8
 124:	c3 a0 00 00 	ret

00000128 <main>:

// main loop
int main(int argc, char **argv)
{
 128:	37 9c ff cc 	addi sp,sp,-52
 12c:	5b 8b 00 34 	sw (sp+52),r11
 130:	5b 8c 00 30 	sw (sp+48),r12
 134:	5b 8d 00 2c 	sw (sp+44),r13
 138:	5b 8e 00 28 	sw (sp+40),r14
 13c:	5b 8f 00 24 	sw (sp+36),r15
 140:	5b 90 00 20 	sw (sp+32),r16
 144:	5b 91 00 1c 	sw (sp+28),r17
 148:	5b 92 00 18 	sw (sp+24),r18
 14c:	5b 93 00 14 	sw (sp+20),r19
 150:	5b 94 00 10 	sw (sp+16),r20
 154:	5b 95 00 0c 	sw (sp+12),r21
 158:	5b 96 00 08 	sw (sp+8),r22
 15c:	5b 9d 00 04 	sw (sp+4),ra

// PATCH YVES TEST COPROCESSEUR
   uint32_t data1,data2,resultat ;
   data1 = 1 ;
   data2 = 2 ;
   asm volatile("user %[dest],%[src1],%[src2],0xAA":[dest] "=r" (resultat):[src1] "r" (data1), [src2] "r" (data2)) ;
 160:	34 0b 00 01 	mvi r11,1
 164:	34 03 00 02 	mvi r3,2
 168:	cd 63 20 aa 	user r4,r11,r3,0xaa
   printf("%x %x %x\r\n",data1,data2,resultat) ;
 16c:	78 01 00 00 	mvhi r1,0x0
 170:	b9 60 10 00 	mv r2,r11
 174:	38 21 00 00 	ori r1,r1,0x0
 178:	f8 00 00 00 	calli 178 <main+0x50>
// PATCH YVES FOR SDRAM IO TEST
volatile uint16_t *pdram = 0x01000000 ;
uint32_t cmpt ;
uint16_t toto ;
   toto = 0 ;
   for(cmpt=0;cmpt<100;cmpt++) { *pdram++ = cmpt % 65536 ;} 
 17c:	78 04 01 00 	mvhi r4,0x100
 180:	b8 80 10 00 	mv r2,r4
 184:	38 42 00 00 	ori r2,r2,0x0
 188:	34 01 00 00 	mvi r1,0
 18c:	78 03 01 00 	mvhi r3,0x100
 190:	0c 41 00 00 	sh (r2+0),r1
 194:	38 63 00 02 	ori r3,r3,0x2
 198:	21 61 ff ff 	andi r1,r11,0xffff
 19c:	35 6b 00 01 	addi r11,r11,1
 1a0:	7d 62 00 64 	cmpnei r2,r11,100
 1a4:	0c 61 00 00 	sh (r3+0),r1
 1a8:	34 63 00 02 	addi r3,r3,2
 1ac:	5c 40 ff fb 	bne r2,r0,198 <main+0x70>
 1b0:	78 0d 01 00 	mvhi r13,0x100
 1b4:	b8 80 60 00 	mv r12,r4
 1b8:	39 8c 00 00 	ori r12,r12,0x0
   pdram = 0x01000000 ;
   for(cmpt=0;cmpt<100;cmpt++) { toto = toto + *pdram++; 
 1bc:	39 ad 00 c8 	ori r13,r13,0xc8
// PATCH YVES FOR SDRAM IO TEST
volatile uint16_t *pdram = 0x01000000 ;
uint32_t cmpt ;
uint16_t toto ;
   toto = 0 ;
   for(cmpt=0;cmpt<100;cmpt++) { *pdram++ = cmpt % 65536 ;} 
 1c0:	34 0b 00 00 	mvi r11,0
 1c4:	78 0e 00 00 	mvhi r14,0x0
   pdram = 0x01000000 ;
   for(cmpt=0;cmpt<100;cmpt++) { toto = toto + *pdram++; 
 1c8:	2d 82 00 00 	lhu r2,(r12+0)
   printf("R:%d\r\n",toto); }   
 1cc:	b9 c0 08 00 	mv r1,r14
uint32_t cmpt ;
uint16_t toto ;
   toto = 0 ;
   for(cmpt=0;cmpt<100;cmpt++) { *pdram++ = cmpt % 65536 ;} 
   pdram = 0x01000000 ;
   for(cmpt=0;cmpt<100;cmpt++) { toto = toto + *pdram++; 
 1d0:	35 8c 00 02 	addi r12,r12,2
 1d4:	b5 62 10 00 	add r2,r11,r2
 1d8:	20 4b ff ff 	andi r11,r2,0xffff
   printf("R:%d\r\n",toto); }   
 1dc:	38 21 00 00 	ori r1,r1,0x0
 1e0:	b9 60 10 00 	mv r2,r11
 1e4:	f8 00 00 00 	calli 1e4 <main+0xbc>
uint32_t cmpt ;
uint16_t toto ;
   toto = 0 ;
   for(cmpt=0;cmpt<100;cmpt++) { *pdram++ = cmpt % 65536 ;} 
   pdram = 0x01000000 ;
   for(cmpt=0;cmpt<100;cmpt++) { toto = toto + *pdram++; 
 1e8:	5d 8d ff f8 	bne r12,r13,1c8 <main+0xa0>
   printf("R:%d\r\n",toto); }   
   

// END PATHC YVES

    printf("\r\n\r\n** TPT LM32 BOOTLOADER **");
 1ec:	78 01 00 00 	mvhi r1,0x0
 1f0:	38 21 00 00 	ori r1,r1,0x0
 1f4:	f8 00 00 00 	calli 1f4 <main+0xcc>

// get cpu cycle counter
static inline uint32_t get_cfg(void) 
{
    uint32_t tmp;
    asm volatile (
 1f8:	90 c0 10 00 	rcsr r2,CFG
   

// END PATHC YVES

    printf("\r\n\r\n** TPT LM32 BOOTLOADER **");
    printf    ("\r\n** CFG REG %08x        **",get_cfg());
 1fc:	78 01 00 00 	mvhi r1,0x0
 200:	78 0f f0 00 	mvhi r15,0xf000
 204:	78 10 f0 00 	mvhi r16,0xf000
 208:	38 21 00 00 	ori r1,r1,0x0
 20c:	78 0e 00 00 	mvhi r14,0x0
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 210:	b9 e0 90 00 	mv r18,r15

    int x = UART_DATA;
 214:	ba 00 98 00 	mv r19,r16
 218:	f8 00 00 00 	calli 218 <main+0xf0>
 21c:	39 ce 00 00 	ori r14,r14,0x0
 220:	78 11 00 00 	mvhi r17,0x0
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 224:	3a 52 00 03 	ori r18,r18,0x3

    int x = UART_DATA;
 228:	3a 73 00 07 	ori r19,r19,0x7
                start = readint(8);
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
 22c:	34 14 00 00 	mvi r20,0
 230:	78 15 00 00 	mvhi r21,0x0
 234:	78 16 00 00 	mvhi r22,0x0

    printf("\r\n\r\n** TPT LM32 BOOTLOADER **");
    printf    ("\r\n** CFG REG %08x        **",get_cfg());
    for(;;) {
        uint32_t start, size, help;
        printf("\r\n>");
 238:	ba 20 08 00 	mv r1,r17
 23c:	38 21 00 00 	ori r1,r1,0x0
 240:	f8 00 00 00 	calli 240 <main+0x118>
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 244:	42 41 00 00 	lbu r1,(r18+0)
 248:	20 21 00 01 	andi r1,r1,0x1
 24c:	64 21 00 00 	cmpei r1,r1,0
 250:	5c 20 ff fd 	bne r1,r0,244 <main+0x11c>

    int x = UART_DATA;
 254:	42 61 00 00 	lbu r1,(r19+0)
        uint8_t c = getchar();

        switch (c) {
 258:	34 21 ff 9b 	addi r1,r1,-101
 25c:	20 21 00 ff 	andi r1,r1,0xff
 260:	74 22 00 11 	cmpgui r2,r1,0x11
 264:	5c 40 ff f5 	bne r2,r0,238 <main+0x110>
 268:	3c 21 00 02 	sli r1,r1,2
 26c:	b4 2e 08 00 	add r1,r1,r14
 270:	28 22 00 00 	lw r2,(r1+0)
 274:	c0 40 00 00 	b r2
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 278:	b9 e0 10 00 	mv r2,r15

    int x = UART_DATA;
 27c:	ba 00 20 00 	mv r4,r16
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 280:	38 42 00 03 	ori r2,r2,0x3

    int x = UART_DATA;
 284:	38 84 00 07 	ori r4,r4,0x7
#define getchar __inline_getchar
static inline int getchar()
{ // get from Rx

    // Waiting for the data to be ready.
    while ((UART_CTRL & 0x01) == 0);
 288:	40 41 00 00 	lbu r1,(r2+0)
 28c:	20 21 00 01 	andi r1,r1,0x1
 290:	64 21 00 00 	cmpei r1,r1,0
 294:	5c 20 ff fd 	bne r1,r0,288 <main+0x160>

    int x = UART_DATA;
 298:	40 81 00 00 	lbu r1,(r4+0)
 29c:	20 23 00 ff 	andi r3,r1,0xff
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
 2a0:	40 41 00 00 	lbu r1,(r2+0)
 2a4:	20 21 00 10 	andi r1,r1,0x10
 2a8:	5c 20 ff fe 	bne r1,r0,2a0 <main+0x178>

    UART_DATA = (char) x;
 2ac:	30 83 00 00 	sb (r4+0),r3
 2b0:	e3 ff ff f6 	bi 288 <main+0x160>
                jump(start);
                break; 
            case 'v': // view memory 
                //putchar('@'); 
                /* read start address */
                start = readint(8);
 2b4:	34 01 00 08 	mvi r1,8
 2b8:	f8 00 00 00 	calli 2b8 <main+0x190>
 2bc:	b8 20 10 00 	mv r2,r1
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
 2c0:	34 01 00 08 	mvi r1,8
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
 2c4:	b8 40 58 00 	mv r11,r2
                //putchar('@'); 
                /* read start address */
                start = readint(8);
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
 2c8:	f8 00 00 00 	calli 2c8 <main+0x1a0>
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
 2cc:	b4 2b 68 00 	add r13,r1,r11
 2d0:	51 6d ff da 	bgeu r11,r13,238 <main+0x110>
 2d4:	ba 80 60 00 	mv r12,r20
                    if (!(help++ & 3)) {
 2d8:	21 81 00 03 	andi r1,r12,0x3
 2dc:	35 8c 00 01 	addi r12,r12,1
 2e0:	44 20 00 0c 	be r1,r0,310 <main+0x1e8>
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
 2e4:	42 41 00 00 	lbu r1,(r18+0)
 2e8:	20 21 00 10 	andi r1,r1,0x10
 2ec:	5c 20 ff fe 	bne r1,r0,2e4 <main+0x1bc>

    UART_DATA = (char) x;
 2f0:	34 01 00 20 	mvi r1,32
 2f4:	32 61 00 00 	sb (r19+0),r1
                        printf("\r\n[");
                        writeint(8, (uint32_t) p32);
                        putchar(']'); 
                    }
                    putchar(' '); 
                    writeint(8, *p32);
 2f8:	29 62 00 00 	lw r2,(r11+0)
 2fc:	34 01 00 08 	mvi r1,8
                start = readint(8);
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
 300:	35 6b 00 04 	addi r11,r11,4
                        printf("\r\n[");
                        writeint(8, (uint32_t) p32);
                        putchar(']'); 
                    }
                    putchar(' '); 
                    writeint(8, *p32);
 304:	f8 00 00 00 	calli 304 <main+0x1dc>
                start = readint(8);
                //putchar('_'); 
                /* read dump size */
                size = readint(8);
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
 308:	55 ab ff f4 	bgu r13,r11,2d8 <main+0x1b0>
 30c:	e3 ff ff cb 	bi 238 <main+0x110>
                    if (!(help++ & 3)) {
                        printf("\r\n[");
 310:	ba a0 08 00 	mv r1,r21
 314:	38 21 00 00 	ori r1,r1,0x0
 318:	f8 00 00 00 	calli 318 <main+0x1f0>
                        writeint(8, (uint32_t) p32);
 31c:	34 01 00 08 	mvi r1,8
 320:	b9 60 10 00 	mv r2,r11
 324:	f8 00 00 00 	calli 324 <main+0x1fc>
#define putchar __inline_putchar
static inline int putchar(const int x)
{ // put in Tx

    // Waiting while the UART is busy.
    while (UART_CTRL & 0x10);
 328:	42 41 00 00 	lbu r1,(r18+0)
 32c:	20 21 00 10 	andi r1,r1,0x10
 330:	5c 20 ff fe 	bne r1,r0,328 <main+0x200>

    UART_DATA = (char) x;
 334:	34 01 00 5d 	mvi r1,93
 338:	32 61 00 00 	sb (r19+0),r1
 33c:	e3 ff ff ea 	bi 2e4 <main+0x1bc>
            case 'r': // reset
                jump(0x00000000);
                break;
            case 'u': // Upload programm
                /* read start address */
                start = readint(8);
 340:	34 01 00 08 	mvi r1,8
 344:	f8 00 00 00 	calli 344 <main+0x21c>
 348:	b8 20 10 00 	mv r2,r1
                /* read program size */
                size = readint(8);
 34c:	34 01 00 08 	mvi r1,8
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
 350:	b8 40 58 00 	mv r11,r2
                break;
            case 'u': // Upload programm
                /* read start address */
                start = readint(8);
                /* read program size */
                size = readint(8);
 354:	f8 00 00 00 	calli 354 <main+0x22c>
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
 358:	b4 2b 60 00 	add r12,r1,r11
 35c:	51 6c ff b7 	bgeu r11,r12,238 <main+0x110>
                    *p = readint(2);
 360:	34 01 00 02 	mvi r1,2
 364:	f8 00 00 00 	calli 364 <main+0x23c>
 368:	31 61 00 00 	sb (r11+0),r1
            case 'u': // Upload programm
                /* read start address */
                start = readint(8);
                /* read program size */
                size = readint(8);
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
 36c:	35 6b 00 01 	addi r11,r11,1
 370:	5d 6c ff fc 	bne r11,r12,360 <main+0x238>
 374:	e3 ff ff b1 	bi 238 <main+0x110>
        switch (c) {
            case 'h': // help
                printf( USAGE );
                break;
            case 'r': // reset
                jump(0x00000000);
 378:	ba 80 08 00 	mv r1,r20
 37c:	f8 00 00 00 	calli 37c <main+0x254>
 380:	e3 ff ff ae 	bi 238 <main+0x110>
        printf("\r\n>");
        uint8_t c = getchar();

        switch (c) {
            case 'h': // help
                printf( USAGE );
 384:	ba c0 08 00 	mv r1,r22
 388:	38 21 00 00 	ori r1,r1,0x0
 38c:	f8 00 00 00 	calli 38c <main+0x264>
 390:	e3 ff ff aa 	bi 238 <main+0x110>
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
                    *p = readint(2);
                }
                break;
            case 'g': // go
                start = readint(8);
 394:	34 01 00 08 	mvi r1,8
 398:	f8 00 00 00 	calli 398 <main+0x270>
                jump(start);
 39c:	f8 00 00 00 	calli 39c <main+0x274>
 3a0:	e3 ff ff a6 	bi 238 <main+0x110>
