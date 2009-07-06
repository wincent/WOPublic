//
//  WOEnumerate.h
//  WOCommon (imported from WODebug)
//
//  Created by Wincent Colaiuta on 12 October 2004.
//  Copyright 2004-2008 Wincent Colaiuta.

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
