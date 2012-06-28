/*
* uartmapping.h
*
*
* Tavail pour COMELEC380 - Kellya CLANZIG et Flavia CORREIA TOVO
*
*/

//---------------------------------------------------------------------------
// Wishbone UART 
//
// Register Description:
//
//    0x00 UCR      [ 0 | 0 | 0 | tx_busy | 0 | 0 | rx_error | rx_avail ]
//    0x04 DATA
//
//---------------------------------------------------------------------------

// tx_busy == 0 -> we can write
// tx_busy == 1 -> UART busy
// rx_error == 0 -> any problem
// rx_error == 1 -> problem with stop bit
// rx_avail == 0 -> data not ready
// rx_avail == 1 -> data available

//  s3_addr   ( 15'h7000 ),    // uart0

#ifndef UARTMAPPING_H
#define UARTMAPPING_H

#define  UART_BASE  ((volatile unsigned char *) 0xF0000000)
#define  UART_DATA  *(UART_BASE + 7)
#define  UART_CTRL  *(UART_BASE + 3)

#endif

