/************************************************************
 *
 * file ram_init.c
 * Code to move the data section from
 * rom to ram and to clear th bss
 *
 * Maintainers: tarik.graba@telecom-paristech.fr
 *
 ************************************************************/

void ram_init() {

    // defined by linker script
    extern long __end_of_text__;
    extern long __data_start__, __data_end__;
    extern long __bss_start__, __bss_end__;

    long *src = &__end_of_text__;
    long *dst = &__data_start__;

    // copy data section to sram
    while (dst < &__data_end__)
        *dst++ = *src++;

    // clear bss
    for (dst = &__bss_start__; dst < &__bss_end__; dst++)
        *dst = 0;

}
