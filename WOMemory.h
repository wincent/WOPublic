//
// WOMemory.h
// WOPublic
//
// Created by Wincent Colaiuta on 10 December 2007.
// Copyright 2007 Wincent Colaiuta.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

static inline void *wmalloc(size_t size)
{
    void *buffer = malloc(size);
    if (!buffer)
        [NSException raise:NSMallocException format:@"malloc of %d bytes failed", size];
    return buffer;
}

//! Wrapper for CFMakeCollectable with an additional check that makes it safe to pass NULL values.
static inline CFTypeRef WOMakeCollectable(CFTypeRef ref)
{
    if (ref)
        ref = CFMakeCollectable(ref);
    return ref;
}
