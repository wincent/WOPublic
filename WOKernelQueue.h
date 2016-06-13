// WOKernelQueue.h
// WOPublic
//
// Copyright 2005-present Greg Hurrell. All rights reserved.
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
#import <AppKit/AppKit.h>   /* NSWorkspace */

//! See man kqueue for more information about these flags.
#define WO_DEFAULT_KQUEUE_FLAGS                                             \
        (NOTE_DELETE | /* unlink() system call was called on file */        \
         NOTE_WRITE  | /* a write occurred */                               \
         NOTE_EXTEND | /* file was extended */                              \
         NOTE_ATTRIB | /* file had its attributes changed */                \
         NOTE_LINK   | /* link count on the file changed */                 \
         NOTE_RENAME | /* file was renamed */                               \
         NOTE_REVOKE)  /* access revoked via revoke() or filesystem unmounted */

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_DELETE kernel notification is received.
extern NSString *WOKernelQueueDeleteNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_WRITE kernel notification is received.
extern NSString *WOKernelQueueWriteNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_EXTEND kernel notification is received.
extern NSString *WOKernelQueueExtendNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_ATTRIB kernel notification is received.
extern NSString *WOKernelQueueAttribNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_LINK kernel notification is received.
extern NSString *WOKernelQueueLinkNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_RENAME kernel notification is received.
extern NSString *WOKernelQueueRenameNotification;

//! Notification posted to the NSWorkspace notification center whenever a
//! NOTE_REVOKE kernel notification is received.
extern NSString *WOKernelQueueRevokeNotification;

//! \warning In order to function correctly this class sets the SIGIO default
//! signal handler action to SIG_IGN (signal ignore). If your application must
//! install a signal handler for that action then you should refrain from using
//! this class.
@interface WOKernelQueue : NSObject {

    //! File descriptor for the kernel queue.
    int             kernelQueue;

    //! Paths that are being monitored.
    NSMutableArray  *monitoredPaths;

}

- (id)init;
- (id)initWithPath:(NSString *)aPath;
- (id)initWithPath:(NSString *)aPath notify:(u_int)fflags;
- (id)initWithPaths:(NSArray *)paths;

//! The designated initializer.
- (id)initWithPaths:(NSArray *)paths notify:(u_int)fflags;

- (void)addPath:(NSString *)aPath;
- (void)addPaths:(NSArray *)paths;
- (void)addPath:(NSString *)aPath notify:(u_int)fflags;
- (void)addPaths:(NSArray *)paths notify:(u_int)fflags;

- (void)removePath:(NSString *)aPath;
- (void)removePaths:(NSArray *)paths;
- (void)removeAllPaths;

@end
