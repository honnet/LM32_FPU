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



int main(void) {

   printf("Hello from LM32\n\r");
   
   float data1,data2,resultat ;
   char ba[80], bb[80], bc[80] ;
   data1 = (float) 1.0f ;
   data2 = (float) -16.0f ;
   resultat = (float) 0.0 ;
   asm volatile("user %[dest],%[src1],%[src2],0x02":[dest] "=r" (resultat):[src1] "r" (data1), [src2] "r" (data2)) ;
   printf("A:%x\r\n",data1) ;
   printf("B:%x\r\n",data2) ;
   printf("C:%x\r\n",resultat) ;
    getchar();
    return 0;
}
