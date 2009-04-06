// WOArgumentArray.h
// WODebug
//
// Copyright 2006-2009 Wincent Colaiuta.

// system headers
#import <Foundation/Foundation.h>

//! WOArgumentArray is an array-like class for conveniently managing arguments.
//!
//! Despite its name it is not a true NSArray subclass. It follows the same
//! conventions as getopt_long (see the getopt_long man page):
//!
//! - Options may be provided in two forms: words (long options) or characters
//!   (short options).
//! - Short options consist of a single character preceeded by a hyphen.
//! - An argument to a short option may be specified with a space followed by
//!   the argument itself.
//! - Long options consist of a word (or hyphen-separated words) preceded by two
//!   consecutive hyphens.
//! - An argument to a long option may be specified with an equals sign (no
//!   spaces) followed by the argument itself.
//! - Options without arguments are treated as BOOLs (YES or NO).
//! - Boolean short options can only be explicitly set to YES. They cannot
//!   explicitly be set to NO, they can only be omitted.
//! - Boolean long options by default are considered to be set to YES. To
//!   explicitly set them to no the option name must be preceeded by the string
//!   "no-". For example, to invert the sense of the boolean option "--limit"
//!   the argument should be passed as "--no-limit".
//!
//! It is not possible for WOArgumentArray to differentiate between ambiguous
//! cases such as the following:
//!
//! \code
//! -a alice --name bob --no-limit -c -d
//! \endcode
//!
//! Is "alice" the argument to the "a" option or is "a" a boolean option and
//! "alice" a separate argument? Likewise is "bob" the argument to the "name"
//! option or is "name" a boolean option and "bob" is a separate argument? The
//! only unambiguous arguments in the example are the "no-limit" option which
//! is a clearly a boolean option set to NO, and the "c" and "d" options which
//! must be boolean because they are not followed by any non-option argument.
//!
//! It is therefore up to the caller to use the appropriate methods so as to
//! avoid ambiguity. For boolean options, the boolForOption: method should be
//! used. For non-boolean options, the argumentForOption: method should be used.
//! Invoking boolForOption: in the example above would yield YES, YES, NO, YES
//! and YES for "a", "name", "limit", "c" and "d" respectively. Invoking
//! argumentForOption: would yield "alice", "bob", nil, nil and nil.
//!
//! \warning WOArgumentArray is not totally threadsafe. It should be safe for
//! multiple threads to access an already-initialized WOArgumentArray object
//! but attempts at manipulating (changing the stored arguments array) by
//! multiple threads may lead to undefined behaviour.
@interface WOArgumentArray : NSObject {
    NSArray *arguments;
}

//! Convenience method that returns a WOArgumentArray object.
//!
//! \p anArray should be an array of NSString arguments such as that obtained
//! by:
//!
//! \code
//! [[NSProcessInfo processInfo] arguments]
//! \endcode
//!
//! \warning Passing an array containing non-NSString objects may lead to
//! undefined behaviour.
+ (id)arrayWithArray:(NSArray *)anArray;

//! Designated initializer.
//!
//! \p anArray should be an array of NSString arguments such as that obtained
//! by:
//!
//! \code
//! [[NSProcessInfo processInfo] arguments]
//! \endcode
//!
//! \warning Passing an array containing non-NSString objects may lead to
//! undefined behaviour.
- (id)initWithArray:(NSArray *)anArray;

//! Returns the number of arguments in the receiver.
- (unsigned)count;

//! \p option may be a single-letter option such as "h" or "v" or a long-form
//! option such as "help", "verbose" or "limit-rate".  WOArgumentArray parses
//! the arguments list looking for matches.
//!
//! When searching for matches will search consider single-letter options
//! preceded be a hyphen to be set (that is, "-h" and "-v" are considered to be
//! set). Long-form options preceded by two consecutive-hyphens will be
//! considered to be set. Long-form options preceded by two consecutive hyphens
//! and the string "no-" will considered to be unset (that is, "--limit-rate" is
//! considered to be set and "--no-limit-rate" is considered to be unset).
//! Returns nil if \p option is nil or is not found in the arguments list. If
//! the option appears multiple times in the  argument list only the first valid
//! occurrence is processed.
- (NSString *)argumentForOption:(NSString *)option;

//! Returns NO if option is nil or is not found in the arguments list. If the
//! option appears multiple times in the arguments list only the first valid
//! occurrence is processed.
- (BOOL)boolForOption:(NSString *)option;

//! Returns the argument at the index specified by \p index, making no
//! distinction between option and non-option arguments. Raises an
//! NSRangeException is \p index is outside the range of the receiver.
- (NSString *)argumentAtIndex:(unsigned)index;

//! Returns an array of NSStrings starting with the argument at \p index up to
//! and including the last argument.
//!
//! Raises an NSRangeException is \p index is outside the range of the receiver.
- (NSArray *)argumentsFromIndex:(unsigned)index;

//! Returns YES if the argument at \p index begins with the prefix "-".
//!
//! The determination is made using a simple prefix comparison; no attempt is
//! made to further parse the argument to determine validity. Raises an
//! NSRangeException if \p index is outside the range of the receiver.
- (BOOL)argumentIsOptionAtIndex:(unsigned)index;

#pragma mark -
#pragma mark Accessors

- (NSArray *)arguments;
- (void)setArguments:(NSArray *)anArguments;

@end
