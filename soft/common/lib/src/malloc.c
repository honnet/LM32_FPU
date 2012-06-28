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

#include "system.h"


#include "stdlib.h"

static void *heap_pointer = 0;

static inline char *align(char *ptr)
{
    return (void*)((unsigned long)(ptr+15)&~0xf);
}

void *malloc( size_t sz )
{
    char *rp;
    if ( ! heap_pointer )
        heap_pointer = align((void*)&_heap);
    rp = heap_pointer;
    heap_pointer = align(rp+sz);
    return rp;
}

