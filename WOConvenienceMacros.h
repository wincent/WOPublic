// WOConvenienceMacros.h
// WOPublic
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
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

//! Stringifies \p entity
//!
//! If \p entity is a macro then only its name will be stringified. To stringify
//! the contents of a macro use WO_STRINGIFY_CONTENTS.
#define WO_STRINGIFY(entity) #entity

//! Double-stringifies \p macro
//!
//! If \p is a macro, stringifies the contents of the macro; if \p is not a
//! macro, merely stringifies it.
#define WO_STRINGIFY_CONTENTS(macro) WO_STRINGIFY(entity)

//! Mark symbols for export
//!
//! The "used" attribute protects exported symbols from falling victim to the
//! linker's dead-code stripping. The "visibility" attribute ensure that
//! exported symbols are globally visible even when symbols are set to be hidden
//! by default (the GCC_SYMBOLS_PRIVATE_EXTERN build setting).
#define WO_EXPORT __attribute__((used)) __attribute__((visibility("default")))

//! Mark classes for export
//!
//! This macro, if included inside a class implementation, prevents the
//! corresponding .objc_class_name symbol from being stripped by dead-code
//! stripping. This is useful when combining dead-code stripping with the
//! BUNDLE_LOADER build setting.
//!
//! \param class The class whose name should be protected from dead-code
//! stripping. The use of the WO_STRINGIFY macro (effectively
//! double-stringifying) ensures that even if \p class is a macro (as is the
//! case when using an obfuscation header) the macro contents will be
//! stringified rather than the name of the macro itself; if \p class is not a
//! macro then it will be stringified normally.
#define WO_CLASS_EXPORT(class) \
        __asm__ (".no_dead_strip .objc_class_name_" WO_STRINGIFY(class) "\n");

#define WO_INLINE static inline __attribute__((always_inline))

//! Shorthand for marking methods and functions as deprecated (generates
//! compiler warnings if those functions or methods are used)
#define WO_DEPRECATED __attribute__((deprecated))

//! Declare a static constructor function to be called as soon as a module is
//! loaded (after +load but before main())
//!
//! A safe replacement for +load in categories and classes (where no official
//! guarantees are offered that it is safe to send any Objective-C messages).
//!
//! \sa http://googlemac.blogspot.com/2006/11/getting-loaded.html
//! \sa http://developer.apple.com/documentation/developertools/Conceptual/DynamicLibraries/Articles/DynamicLibraryDesignGuidelines.html
#define WO_LOAD __attribute__((constructor)) static void

//! For symmetry with WO_LOAD.
#define WO_UNLOAD __attribute__((destructor)) static void

//! \name Category linker warning helpers
//!
//! These macros are used internally in WOPublic to trigger linker errors if
//! code that depends on a category imports a header file but the implementation
//! file is not compiled in the build process.
//!
//! \startgroup

#define WO_CATEGORY_MARKER_(ClassName, CategoryName) \
        __attribute__((used)) __attribute__((visibility("default"))) \
        int ClassName ## CategoryName

//! Adds a level of indirection that allows obfuscated class and category names
//! to be passed to WO_CATEGORY_MARKER_.
#define WO_CATEGORY_MARKER(ClassName, CategoryName) \
        WO_CATEGORY_MARKER_(ClassName, CategoryName)

//! Declares the existence of a unique external symbol and references it
//!
//! For use within a category interface file. Any code which uses a category and
//! imports its header file will see this external reference. This allows code
//! to receive link-time confirmation that the desired category implementation
//! was indeed included in the compilation phase.
#define WO_DECLARE_CATEGORY_MARKER_(ClassName, CategoryName) \
        extern int ClassName ## CategoryName; \
        static __attribute__((used)) \
        int *ClassName ## CategoryName ## _ref = &ClassName ## CategoryName

//! Adds a level of indirection that allows obfuscated class and category names
//! to be passed to WO_DECLARE_CATEGORY_MARKER_.
#define WO_DECLARE_CATEGORY_MARKER(ClassName, CategoryName) \
        WO_DECLARE_CATEGORY_MARKER_(ClassName, CategoryName)

//! \endgroup

//! Shorthand for defining an NSArray with a variable number of elements. It is not necessary to follow the last element with nil.
//! The enclosing parentheses serve to make the macro suitable for use inside other macros, for example:
//!
//!     \code
//!     WO_ARRAY(WO_STRING(@"foo%x", foo), WO_ARRAY(@"foo"));
//!     \endcode
//!
#define WO_ARRAY(...) ([NSArray arrayWithObjects:__VA_ARGS__, nil])

//! Shorthand for defining an NSSet with a variable number of elements. It is not necessary to follow the last element with nil.
//! The enclosing parentheses serve to make the macro suitable for use inside other macros, see WO_ARRAY for an example.
#define WO_SET(...) ([NSSet setWithObjects:__VA_ARGS__, nil])

//! Shorthand for defining an NSMutableArray with a variable number of elements. It is not necessary to follow the last element with nil.
//! The enclosing parentheses serve to make the macro suitable for use inside other macros, see WO_ARRAY for an example.
#define WO_MUTABLE_ARRAY(...) ([NSMutableArray arrayWithObjects:__VA_ARGS__, nil])

//! Shorthand for defining an NSMutableSet with a variable number of elements. It is not necessary to follow the last element with nil.
//! The enclosing parentheses serve to make the macro suitable for use inside other macros, see WO_ARRAY for an example.
#define WO_MUTABLE_SET(...) ([NSMutableSet setWithObjects:__VA_ARGS__, nil])

//! Shorthand for defining an NSString based on a format string.
//!
//! \code
//! WO_STRING(@"foo");
//! WO_STRING(@"foo %d", bar);
//! \endcode
#define WO_STRING(...) [NSString stringWithFormat:__VA_ARGS__]

//! Shorthand for defining an NSMutableString based on a format string.
//!
//! \code
//! WO_MUTABLE_STRING(@"foo");
//! WO_MUTABLE_STRING(@"foo %d", bar);
//! \endcode
#define WO_MUTABLE_STRING(...) [NSMutableString stringWithFormat:__VA_ARGS__]

//! Shorthand for returning an NSNumber object initialized with a BOOL value of YES.
#define WO_YES [NSNumber numberWithBool:YES]

//! Shorthand for returning an NSNumber object initialized with a BOOL value of NO.
#define WO_NO [NSNumber numberWithBool:NO]

//! Shorthand for returning an NSNumber object initialized with a BOOL value. The value may be literal YES or NO, or and expression to be evaluated.
//! The double negation is used to ensure that a real boolean value is obtained; without it values large enough to overflow the storage for the BOOL type could produce incorrect results when cast to BOOL.
#define WO_BOOL(arg) [NSNumber numberWithBool:!!(arg)]

//! Shorthand for returning an NSNumber object initialized with an int value.
#define WO_INT(arg) [NSNumber numberWithInt:(arg)]

//! Shorthand for returning an NSNumber object initialized with an unsigned int value.
#define WO_UNSIGNED(arg) [NSNumber numberWithUnsignedInt:(arg)]

//! Shorthand for returning an NSNumber object initialized with an float value.
#define WO_FLOAT(arg) [NSNumber numberWithFloat:(arg)]

//! Convenience macro for use in logging debugging information to the console.
//! If \p expr evaluates to true then the macro evaluates to the NSString
//! @"YES", otherwise evaluates to @"NO".
#define WO_STRING_FROM_BOOL(expr) ((expr) ? @"YES" : @"NO")
