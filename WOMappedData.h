// WOMappedData.h
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.
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

// system headers
#import <Foundation/Foundation.h>

//! WOMappedData is not a real NSData subclass (due to the difficulty of
//! subclassing within a class cluster) but it is a compound object that behaves
//! much like an NSData subclass. It can be used to perform a mapped read of
//! (potentially very large) files into a page aligned buffer.
@interface WOMappedData : NSObject {

    //! Embedded NSData object (compound object).
    NSData      *embeddedData;

    //!  Actual data storage.
    const void  *buffer;

    //! Buffer length.
    ssize_t      bufferSize;
}

//! Convenience factory method.
//!
//! Raises an NSInternalInconsistencyException exception if \p path is nil.
+ (id)dataWithContentsOfFile:(NSString *)path;

//!  Designated initializer.
//!
//! Raises an NSInternalInconsistencyException exception if \p path is nil.
- (id)initWithContentsOfFile:(NSString *)path;

//! Returns length of data stored in the receiver.
- (ssize_t)size;

//! Returns a pointer to the receiver’s contents.
- (const void *)bytes;

//! Direct access to embedded data object.
- (NSData *)embeddedData;

@end
