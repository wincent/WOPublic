// WOMemory.h
// WOPublic
//
// Copyright 2007-2009 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

static inline void *wmalloc(size_t size)
{
    void *buffer = malloc(size);

    // POSIX allows size to be 0, so explicitly check for ENOMEM
    if (!buffer && errno == ENOMEM)
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

//! Wrapper for CFRelease with an additional check that makes it safe to pass NULL values.
static inline void WOCFRelease(CFTypeRef ref)
{
    if (ref)
        CFRelease(ref);
}
