/************************************************************
 *
 * file bss_init.c
 * Code to move the data section from
 * rom to ram and to clear th bss
 *
 * Maintainers: tarik.graba@telecom-paristech.fr
 *
 ************************************************************/

void bss_init() {

    // defined by linker script
    extern long __bss_start__, __bss_end__;

    long *dst ;

    // clear bss
    for (dst = &__bss_start__; dst < &__bss_end__; dst++)
        *dst = 0;

}
