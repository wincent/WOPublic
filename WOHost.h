// WOHost.h
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "WOObject.h"

//! The WOHost class uses functions from the SystemConfiguration framework to test for host reachability. For efficiency it caches host reachability information and updates that information on demand by using a SystemConfiguration callback function. See:  http://developer.apple.com/samplecode/SimpleReach/SimpleReach.html
//!
//! Prior to Mac OS X 10.3 the SystemConfiguration framework featured synchronous host reachability functions that under some circumstances the SystemConfiguration calls can block for lengthy periods (60 seconds) while determining initial reachability. The new APIs in 10.3 are asynchronous and depend on the existence of a CFRunLoop. It is advisable to initialize new WOHost objects in the main thread of the application if you suspect that other potential threads are going to be short-lived (because when they exit they terminate their CFRunLoop and the WOHost object will not receive any callbacks).
//!
//! Required frameworks:
//!     - SystemConfiguration
//!
@interface WOHost : WOObject {

    NSString                        *hostName;
    BOOL                            reachable;

    SCNetworkReachabilityRef        ref;
    SCNetworkReachabilityContext    context;

}

#pragma mark -
#pragma mark Shared host registry

/*!

\name Shared host registry

 The hostWithHostName: and initWithHostName: methods automatically ensure that only one WOHost object exists for any given host. The hostForHostName: and setHost:forHostName: methods provide an alternative design pattern more like that used by NSValueTransformer for explicitlty managing a shared registry of known WOHost objects.

\startgroup

*/

/*! Returns a previously registered WOHost instance for the host corresponding to \p aHostName. Returns nil if no such WOHost object exists. Raises an NSInternalInconsistencyException if \p aHostName is nil. */
+ (WOHost *)hostForHostName:(NSString *)aHostName;

/*! Registers \p aHost as the WOHost instance that corresponds to \p aHostName. This method is so-named for consistency with the shared registry design pattern as embodied in NSValueTransformer. Raises an NSInternalInconsistencyException if either \p aHost is nil, or if host name of the passed WOHost object does not match \p aHostName. Note that because WOHost objects are mutable, care must be taken to avoid an inconsistent state in the shared registry; this can happen if a host is added to the registry and its host name is later changed, but in the shared registry it continues to be identified by the host name original passed as \p aHostName when setHost:forHostName: was originally called. No attempt is made to avoid this kind of inconsistency; it is the responsibility of the caller to avoid or be prepared for such inconsistencies. To remove a host from the registry, pass nil for \p aHost. */
+ (void)setHost:(WOHost *)aHost forHostName:(NSString *)aHostName;

/*! \endgroup */

#pragma mark -
#pragma mark Creating/obtaining WOHost instances

/*! Convenience method for obtaining access to a WOHost object for a given host. Each time a new WOHost object is created using initWithHostName: a reference to it is kept by the WOHost class. When hostWithHostName: is called the internal list of existing WOHost objects is checked to see if one already exists and if it does then it is returned; otherwise it is created and added to the list. Raises an NSInvalidArgumentException if \p aHostName is nil. */
+ (id)hostWithHostName:(NSString *)aHostName;

/*! Designated initializer. If an existing WOHost object already exists for a given host name then the existing object is returned instead. Raises an NSInvalidArgumentException if \p aHostName is nil. */
- (id)initWithHostName:(NSString *)aHostName;

#pragma mark -
#pragma mark Properties

/*! This method is more than a simple accessor method for setting an instance variable; on setting a new host name it unregisters any existing callback and then reregisters a new callback corresponding to the new host name. Note that due to the one-object-per-host behaviour of this class, if \p aHostName corresponds to an already-existing WOHost object then an NSInternalInconsistencyException will be raised. */
@property(copy) NSString *hostName;

//! Returns YES if host can be reached without initiating a new network connection (for example, a dial-up connection).
@property(readonly, getter=isReachable) BOOL reachable;

@end

#pragma mark -
#pragma mark Notifications

/*! Posted to the application's default NSNotificationCenter when a host becomes reachable, with the corresponding WOHost object as object. */
extern NSString *WOHostDidBecomeReachableNotification;

/*! Posted to the application's default NSNotificationCenter when a host becomes unreachable, with the corresponding WOHost object as object. */
extern NSString *WOHostDidBecomeUnreachableNotification;
