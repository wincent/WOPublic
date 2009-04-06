// WOMappedData.h
// WODebug
//
// Copyright 2006-2009 Wincent Colaiuta.

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
