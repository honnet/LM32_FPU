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

void *memcpy( void *_dst, void *_src, size_t size )
{
    uint32_t *dst = _dst;
    uint32_t *src = _src;
    if ( ! ((uint32_t)dst & 3) && ! ((uint32_t)src & 3) )
        while (size > 3) {
            *dst++ = *src++;
            size -= 4;
        }

    unsigned char *cdst = (unsigned char*)dst;
    unsigned char *csrc = (unsigned char*)src;

    while (size--) {
        *cdst++ = *csrc++;
    }
    return _dst;
}
