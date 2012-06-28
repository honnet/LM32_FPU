/***************************************************
 *
 * LM32 startup code and exceptions handlers
 * This is based on the exception hnadler exemple
 * which can be found in the :
 *       "LatticeMico32 Processor Reference Manual"
 * And the u-boot start.S from Theobroma Systems  
 *        <www.theobroma-systems.com>
 *
 * Maintainers: tarik.graba@telecom-paristech.fr
 *
 ***************************************************/

/* ALL EXCEPTION HANDLERS ARE 8word (32bytes) long 
 * AND MUST ALIGNED
 */

/*
        System call convention:
        - System call number in register r8
        - Return value in r1 ( and r2 only if 64-bit value)
*/
.section .boot, "ax", @progbits
/* START OF EXCEPTION HANDLER */
    .global     _start
_start:
_reset_handler:
    xor  r0, r0, r0
    wcsr IE,r0 /* disable interrupts */
    wcsr IM,r0 /* mask all interrupts */
    mvhi    r1, hi(_reset_handler) 
    ori     r1, r1, lo(_reset_handler)
    wcsr    EBA, r1 /* Set Exception base address */
    bi _stack_set
    nop
_breakpoint_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_instruction_bus_error_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_watchpoint_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_data_bus_error_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_divide_by_zero_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_interrupt_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop
_system_call_handler:
    bi _reset_handler
    nop
    nop
    nop
    nop
    nop
    nop
    nop

/* END OF EXCEPTION HANDLER */

_stack_set:
    /* Setup stack and global pointer */
    mvhi    sp, hi(__stack)
    ori     sp, sp, lo(__stack)

    /* Set .data .bss */
_ram_init:
    calli     ram_init 

    /* Jump to main program */
gotomain:
    calli   main

    /* If we return from main ...*/   
.global _exit
_exit:
    /* If breakpoint handler is not modified this 
     * will reset the cpu */
    bi _reset_handler
    /* break */

