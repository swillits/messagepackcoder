
MessagePackCoder
=============

The MsgPackArchiver and MsgPackUnarchiver classes are drop-in replacements for
NSKeyedArchiver and NSKeyedUnarchiver, which use the MessagePack protocol for storage.


Benefits
-------------
MsgPackArchiver and MsgPackUnarchiver are significantly faster (multiple times) than
the standard Cocoa classes and use less space to store the data, while still being
NSCoder subclasses.


Caveats
-------------
Part of the performance gain is by the MsgPack coder explicitly handling NSString,
NSArray, and NSDictionary, that is,  _not_ relying on their NSCoding implementations.
This means when you decode a string/array/dictionary using MsgPackUnarchiver, it will
create NSString/NSArray/NSDictionary instances, not instances of your given subclass.


Stability
-------------
There are unit tests demonstrating the code works (at least with the given
test cases) but there's no guarantee of production readiness at the moment. If you'd
like to use it, please review the code and make any contributions. (This was mostly
a quick hackathon project.)


Requirements
-------------

This project uses "CMP", which is a C implementation of the MessagePack protocol.
You can find that project here: https://github.com/camgunz/cmp
CMP has a friendly MIT license.

There are no OS version requirements for this code, but it currently uses MRC only.



License
-------------

Portions not including "CMP" are copyright (c) 2014, Seth Willits

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

The Software is provided "as is", without warranty of any kind, express or implied, 
including but not limited to the warranties of merchantability, fitness for a 
particular purpose and noninfringement. In no event shall the authors or copyright 
holders be liable for any claim, damages or other liability, whether in an action of 
contract, tort or otherwise, arising from, out of or in connection with the Software 
or the use or other dealings in the Software.

--

In plain English: do whatever you want with it, and no you do not need to give me
credit in your application/documentation. 


