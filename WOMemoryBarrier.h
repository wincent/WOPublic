// WOMemoryBarrier.h
// WOPublic
//
// Copyright 2004-present Greg Hurrell. All rights reserved.
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

//! \file
//! Memory barrier macros for i386/SSE and i386
//!
//! This file provides a full bi-directional memory barrier macro,
//! WO_MEMORY_BARRIER, and the following uni-directional barriers:
//!
//! - the WO_WRITE_MEMORY_BARRIER; also known as a "store" or "release" memory
//!   barrier, or an "upwards fence": all stores before the barrier are
//!   guaranteed to take place before any stores after the barrier.
//! - the WO_READ_MEMORY_BARRIER; also known as a "load" or "acquire" memory
//!   barrier, or a "downwards fence": all loads before the barrier are
//!   guaranteed to take place before any loads after the barrier; a read
//!   barrier is also an implied "data dependency" barrier, guaranteeing the
//!   correct ordering and visibility of two loads where the second load depends
//!   on the result of the first.
//!
//! Memory barriers should always come in pairs. If they are correctly placed
//! they prevent operations performed on one CPU from being seen out-of-order by
//! another CPU, something that would otherwise be possible due to the
//! potentionally aggressive instruction re-ordering performed by modern
//! compilers and CPUs, and the possibility of incoherency between per-processor
//! caches.
//!
//! The following code illustrates correct placement of memory barriers in a
//! singleton implementation that uses the Double-Checked Locking pattern:
//!
//! \code
//! id instance = shared_instance;              // 1
//! WO_READ_MEMORY_BARRIER();                   // 2
//! if (instance == nil)
//! {
//!     @synchronized (object)
//!     {
//!         instance = shared_instance;
//!         if (instance == nil)
//!         {
//!             instance = alloc_instance();    // 3
//!             WO_WRITE_MEMORY_BARRIER();      // 4
//!             shared_instance = instance;     // 5
//!         }
//!     }
//! }
//! return instance;
//! \endcode
//!
//! The principal purpose of the memory barriers in the above example is to
//! ensure that:
//!
//! - only one instance of the singleton is allocated (by the alloc_instance()
//!   function)
//! - the allocation is fully completed before any other threads are allowed to
//!   see the shared instance
//!
//! To imagine the effects of the pair of barriers one must imagine two threads,
//! each on a different processor, trying to execute the code simultaneously.
//! The \@synchronized block already guarantees that only one thread can enter
//! the critical synchronzied section at a time, but without the memory barriers
//! there is no guarantee that another thread won't see the operations
//! <em>inside</em> the critical section as happening in a different order.
//!
//! This is because even a seemingly atomic operation like the following:
//!
//! \code
//! shared_instance = alloc_instance();
//! \endcode
//!
//! Is in actuality a two-step process:
//!
//! \code
//! // allocate an instance
//! instance = alloc_instance();
//!
//! // make "shared_instance" point at allocated instance
//! shared_instance = instance;
//! \endcode
//!
//! On a single-processor machine with a single cache there are no problems with
//! this non-atomicity because the CPU will always see these events as being in
//! the correct order. On a multi-processor machine with multiple caches,
//! however, the order of the events may be perceived differently from different
//! CPUs. This is because when the changes are propagated from one cache to
//! another they may not necessarily be propagated in the same order; the
//! shared_instance pointer may be updated first, for example, <em>before</em>
//! the memory indicated by the pointer (the actual instance) itself is updated.
//!
//! The call to WO_WRITE_MEMORY_BARRIER at "4" prevents any stores from moving
//! past it in either direction; that is, the allocation ("3") must complete
//! before the assignment to the shared_instance variable ("5").
//!
//! The call to WO_READ_MEMORY_BARRIER at "2" is necessary because without it
//! the ordering enforced by the corresponding write barrier would not
//! necessarily be visible from another processor. That is, the read of
//! shared_instance at "1", in conjunction with the read memory barrier at "2",
//! causes all effects prior to the <em>storage</em> of shared_instance (at "5")
//! to be visible; in this case the "effect" that we are interested in is the
//! completion of the alloc_instance() function at "3".
//!
//! Simplifying to the extreme, the write memory barrier effectively alters the
//! state of shared memory, while read memory barrier ensures that the reader
//! sees the new state. Only when used in pairs can these memory barriers offer
//! useful guarantees.
//!
//! \sa http://repo.or.cz/w/linux-2.6.git?a=blob_plain;f=Documentation/memory-barriers.txt
//! \sa http://www.nwcpp.org/Downloads/2004/DCLP_notes.pdf

#if defined(__i386__)
#if defined(__SSE__)

// i386 with SSE
#define WO_READ_MEMORY_BARRIER()    __asm__ __volatile__ ("lfence":::"memory")
#define WO_WRITE_MEMORY_BARRIER()   /* no-op: not needed on i386 */
#define WO_MEMORY_BARRIER()         __asm__ __volatile__ ("mfence":::"memory")

#else /* not defined __SSE__ */

// i386 without SSE
#define WO_READ_MEMORY_BARRIER()    __asm__ __volatile__ ("lock; addl $0,0(%%esp)":::"memory")
#define WO_WRITE_MEMORY_BARRIER()   /* no-op: not needed on i386 */
#define WO_MEMORY_BARRIER()         __asm__ __volatile__ ("lock; addl $0,0(%%esp)":::"memory")

#endif
#else

#warning Unsupported architecture

// fall back to OS-level, bi-directional fences
#define WO_READ_MEMORY_BARRIER()    OSMemoryBarrier()
#define WO_WRITE_MEMORY_BARRIER()   OSMemoryBarrier()
#define WO_MEMORY_BARRIER()         OSMemoryBarrier()

#endif

//! Shortcut macro encapsulating the double-checked locking pattern with
//! memory barriers for safe singleton initialization.
//!
//! Usage:
//!
//! \code
//! id myGlobalVariable = nil;
//! + (id)mySingleton
//! {
//!     // use double-checked locking pattern with memory barriers
//!     // to safely initialize and return myGlobalVariable using
//!     // [[self alloc] init]:
//!     WO_DCLP_INIT(myGlobalVariable, [[self alloc] init]);
//! }
//! \endcode
#define WO_RETURN_DCLP_INIT(sharedVar, initializer) \
    id instance = sharedVar;                        \
    WO_READ_MEMORY_BARRIER();                       \
    if (!instance)                                  \
    {                                               \
        @synchronized (self)                        \
        {                                           \
            instance = sharedVar;                   \
            if (!instance)                          \
            {                                       \
                instance = (initializer);           \
                WO_WRITE_MEMORY_BARRIER();          \
                sharedVar = instance;               \
            }                                       \
        }                                           \
    }                                               \
    return instance;
