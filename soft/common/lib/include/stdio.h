/*
 *
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
 * Maintainers: nipo
 * Modified by T. Graba (Telecom Paris-TECH) for ELEC342
 */
#ifndef STDIO_H_
#define STDIO_H_

#define assert(x) \
    do {																	\
        if ( !(x) ) {														\
            printf("Assertion `%s' failed !!!\n", #x);		\
        }																	\
    } while (0)

/* #define assert(x) \ */
/* do {																	\ */
/* 	if ( !(x) ) {														\ */
/* 		printf("Assertion `%s' failed !!!\n", #x);		\ */
/* 		abort();														\ */
/* 	}																	\ */
/* } while (0) */

char* strcpy( char *dst, const char *src );
int   printf( const char *fmt, ... );
int   strcmp( const char *, const char *);
void* memcpy( void *_dst, void *_src, unsigned long size );
char* ftoa(char *st, float f, int flags) ;
 
/* time function should not be here */
int time();

#endif

