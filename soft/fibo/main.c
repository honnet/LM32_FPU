/*
 * SOCLIB_GPL_HEADER_BEGIN
 * 
 * This file is part of SoCLib, GNU GPLv2.
 * 
 * SoCLib is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 * 
 * SoCLib is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SoCLib; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 * 
 * SOCLIB_GPL_HEADER_END
 *
 * Copyright (c) UPMC, Lip6, SoC
 *         Nicolas Pouillon <nipo@ssji.net>, 2006-2007
 *
 * Maintainers: tarik.graba@telecom-paristech.fr
 */

/*
Programme soft simple, "Hello word" qui ecrit de plus quelques termes de la suite de Fibonacci. Pour l'instant, l'utilisation de la fonction time(int* a) ne fonctionne pas.
*/

#include "stdio.h"
#include "system.h"


int fibo(int n) {
    if (n==0)
        return 1;
    else if (n==1)
        return 1;
    else return fibo(n-1) + fibo(n-2);
}

int main(void) {
    unsigned int start_time;
    start_time = time ( (int*) 0);

    printf("Hello from LM32, at start cpu cycle offset %u \n\r", start_time);

    printf("Start CPU cycle %u\n\r",time ( (int*) 0) - start_time);

    printf("Fibo(1) = %d\n\r", fibo(1));
    printf("Fibo(2) = %d\n\r", fibo(2));
    printf("Fibo(3) = %d\n\r", fibo(3));
    printf("Fibo(4) = %d\n\r", fibo(4));
    printf("Fibo(5) = %d\n\r", fibo(5));
    printf("Fibo(6) = %d\n\r", fibo(6));
    printf("Fibo(7) = %d\n\r", fibo(7));

    printf("End CPU cycle %d\n\r",time ( (int*) 0) - start_time);


    getchar();
    
    return 0;
}
