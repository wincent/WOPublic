// WOEnumerate.h
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

/*! WO_ENUMERATE was a convenience macro for expressing the Objective-C enumerator idiom in more compact form. Instead of the standard, longer form:

<pre>NSEnumerator *enumerator = [collection objectEnumerator];
id object = nil;
while ((object = [enumerator nextObject]))
    NSLog(@"Object: %@", object);</pre>

The following, shorter form was used:

<pre>WO_ENUMERATE(collection, object)
    NSLog(@"Object: %@", object);</pre>

The WO_ENUMERATE macro was also considerably faster than the standard form because is used a cached IMP (implementation pointer) and selector to speed up repeated invocations of the <tt>nextObject</tt> selector. In informal testing (enumerating over a 10,000,000-item array ten times) the macro performed 49% faster than the standard idiom (averaging 3.6 million objects per second compared with 2.4 million per second).

If passed a nil pointer instead of a valid collection, no iterations were performed. If passed an object which did not respond to the objectEnumerator selector then an exception was raised. Both of these behaviours matched the pattern of the standard idiom.

Note that the compiler C dialect must be set to C99 or GNU99 in order to use this macro because of the initialization of variables inside the for expression.

When Apple announced Objective-C 2.0 (for Leopard), which includes a "for" enumeration construct in the language itself, the WO_ENUMERATE macro was marked as deprecated and finally removed. The WO_REVERSE_ENUMERATE and WO_KEY_ENUMERATE are retained because they have no language-level equivalent.

\sa http://mjtsai.com/blog/2003/12/08/cocoa_enumeration/
\sa http://rentzsch.com/papers/improvingCocoaObjCEnumeration/
\sa http://mjtsai.com/blog/2006/07/15/cocoa-foreach-macro/

*/

#ifndef WO_REVERSE_ENUMERATE

#define WO_REVERSE_ENUMERATE(collection, object)                                                                                \
for (id WOMacroEnumerator_ ## object    = [collection reverseObjectEnumerator],                                                 \
     WOMacroSelector_ ## object         = (id)@selector(nextObject),                                                            \
     WOMacroMethod_ ## object           = (id)[WOMacroEnumerator_ ## object methodForSelector:(SEL)WOMacroSelector_ ## object], \
     object = WOMacroEnumerator_ ## object ?                                                                                    \
        ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object,(SEL)WOMacroSelector_ ## object) : nil;                    \
     object != nil;                                                                                                             \
     object = ((IMP)WOMacroMethod_ ## object)(WOMacroEnumerator_ ## object, (SEL)WOMacroSelector_ ## object))

#endif /* WO_REVERSE_ENUMERATE */

#ifndef WO_KEY_ENUMERATE

//! There is no WO_REVERSE_KEY_ENUMERATE macro because by definition keyed collections are unordered
#define WO_KEY_ENUMERATE(collection, key)                                                                               \
for (id WOMacroEnumerator_ ## key   = [collection keyEnumerator],                                                       \
     WOMacroSelector_ ## key        = (id)@selector(nextObject),                                                        \
     WOMacroMethod_ ## key          = (id)[WOMacroEnumerator_ ## key methodForSelector:(SEL)WOMacroSelector_ ## key],   \
     key = WOMacroEnumerator_ ## key ?                                                                                  \
        ((IMP)WOMacroMethod_ ## key)(WOMacroEnumerator_ ## key, (SEL)WOMacroSelector_ ## key) : nil;                    \
     key != nil;                                                                                                        \
     key = ((IMP)WOMacroMethod_ ## key)(WOMacroEnumerator_ ## key, (SEL)WOMacroSelector_ ## key))

#endif /* WO_KEY_ENUMERATE */
