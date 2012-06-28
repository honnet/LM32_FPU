/************************************************************
 *
 * CRT0 for lm32 hello_world
 * This code initialize the stack pointer
 * call ram_init to set data and bss and 
 * then call the main function
 * The return from the main produces a break
 * which could be caught by a debugger
 *
 * Maintainers: tarik.graba@telecom-paristech.fr
 *
 ************************************************************/

.global _crt0
_crt0:
    /* Setup stack and global pointer */
    mvhi    sp, hi(__stack)
    ori     sp, sp, lo(__stack)

    /* Set .bss */
_ram_init:
    calli     bss_init 

    /* Jump to main program */
gotomain:
    calli   main

    /* If we return from main ...*/   
.global _exit
_exit:
    mvhi    r1, hi(__reset)
    ori     r1, r1, lo(__reset)
    b       r1

