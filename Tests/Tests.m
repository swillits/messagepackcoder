//
//  Tests.m
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MsgPackArchiver.h"
#import "MsgPackUnarchiver.h"



@interface Foo : NSObject <NSCoding>
@property (strong) id empty;
@property (strong) NSNull * null;
@property (strong) NSString * string;
@property (strong) NSNumber * number;
@property (strong) NSDictionary * dictionary;
@end



@interface Tests : XCTestCase
@end


@implementation Tests

- (void)setUp
{
	[super setUp];
}

- (void)tearDown
{
	[super tearDown];
}



- (void)testBytes
{
	const char * bytes = "here are some\0'random' bytes.\0All bytes are equal!";
	size_t length = 50;
	
	NSData * data1 = [NSData data];
	NSData * data2 = [NSData dataWithBytesNoCopy:(void *)bytes length:length freeWhenDone:NO];
	
	[self _testRoot:data1];
	[self _testRoot:data2];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeObject:data1 forKey:@"key0"];
	[a encodeObject:data2 forKey:@"key1"];
	[a finishEncoding];

	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqualObjects([u decodeObjectForKey:@"key0"], data1);
	XCTAssertEqualObjects([u decodeObjectForKey:@"key1"], data2);
}








	

- (void)testBool
{
	[self _testRoot:@(YES)];
	[self _testRoot:@(NO)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeBool:YES forKey:@"key0"];
	[a encodeBool:NO forKey:@"key1"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeBoolForKey:@"key0"], YES);
	XCTAssertEqual([u decodeBoolForKey:@"key1"], NO);
}





	

- (void)testInt
{
	[self _testRoot:@(0)];
	[self _testRoot:@(-1)];
	[self _testRoot:@(INT_MAX)];
	[self _testRoot:@(INT_MIN)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeInt:0 forKey:@"key0"];
	[a encodeInt:-1 forKey:@"key1"];
	[a encodeInt:INT_MAX forKey:@"key2"];
	[a encodeInt:INT_MIN forKey:@"key3"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeIntForKey:@"key0"], 0);
	XCTAssertEqual([u decodeIntForKey:@"key1"], -1);
	XCTAssertEqual([u decodeIntForKey:@"key2"], INT_MAX);
	XCTAssertEqual([u decodeIntForKey:@"key3"], INT_MIN);
}





	

- (void)testInt32
{
	[self _testRoot:@(0)];
	[self _testRoot:@(-1)];
	[self _testRoot:@(INT32_MAX)];
	[self _testRoot:@(INT32_MIN)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeInt32:0 forKey:@"key0"];
	[a encodeInt32:-1 forKey:@"key1"];
	[a encodeInt32:INT32_MAX forKey:@"key2"];
	[a encodeInt32:INT32_MIN forKey:@"key3"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeInt32ForKey:@"key0"], 0);
	XCTAssertEqual([u decodeInt32ForKey:@"key1"], -1);
	XCTAssertEqual([u decodeInt32ForKey:@"key2"], INT32_MAX);
	XCTAssertEqual([u decodeInt32ForKey:@"key3"], INT32_MIN);
}





	

- (void)testInt64
{
	[self _testRoot:@(0)];
	[self _testRoot:@(-1)];
	[self _testRoot:@(INT64_MAX)];
	[self _testRoot:@(INT64_MIN)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeInt64:0 forKey:@"key0"];
	[a encodeInt64:-1 forKey:@"key1"];
	[a encodeInt64:INT64_MAX forKey:@"key2"];
	[a encodeInt64:INT64_MIN forKey:@"key3"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeInt64ForKey:@"key0"], 0);
	XCTAssertEqual([u decodeInt64ForKey:@"key1"], -1);
	XCTAssertEqual([u decodeInt64ForKey:@"key2"], INT64_MAX);
	XCTAssertEqual([u decodeInt64ForKey:@"key3"], INT64_MIN);
}





	

- (void)testInteger
{
	[self _testRoot:@(0)];
	[self _testRoot:@(-1)];
	[self _testRoot:@(NSIntegerMax)];
	[self _testRoot:@(NSIntegerMin)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeInteger:0 forKey:@"key0"];
	[a encodeInteger:-1 forKey:@"key1"];
	[a encodeInteger:NSIntegerMax forKey:@"key2"];
	[a encodeInteger:NSIntegerMin forKey:@"key3"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeIntegerForKey:@"key0"], 0);
	XCTAssertEqual([u decodeIntegerForKey:@"key1"], -1);
	XCTAssertEqual([u decodeIntegerForKey:@"key2"], NSIntegerMax);
	XCTAssertEqual([u decodeIntegerForKey:@"key3"], NSIntegerMin);
}





	

- (void)testFloat
{
	[self _testRoot:@(0.0f)];
	[self _testRoot:@(-1.0f)];
	[self _testRoot:@(3.14159265358979323846264338327950288419716939937510f)];
	[self _testRoot:@(FLT_MAX)];
	[self _testRoot:@(FLT_MIN)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeFloat:0.0f forKey:@"key0"];
	[a encodeFloat:-1.0f forKey:@"key1"];
	[a encodeFloat:3.14159265358979323846264338327950288419716939937510f forKey:@"key2"];
	[a encodeFloat:FLT_MAX forKey:@"key3"];
	[a encodeFloat:FLT_MIN forKey:@"key4"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeFloatForKey:@"key0"], 0.0f);
	XCTAssertEqual([u decodeFloatForKey:@"key1"], -1.0f);
	XCTAssertEqual([u decodeFloatForKey:@"key2"], 3.14159265358979323846264338327950288419716939937510f);
	XCTAssertEqual([u decodeFloatForKey:@"key3"], FLT_MAX);
	XCTAssertEqual([u decodeFloatForKey:@"key4"], FLT_MIN);
}





	

- (void)testDouble
{
	[self _testRoot:@(0.0)];
	[self _testRoot:@(-1.0)];
	[self _testRoot:@(3.14159265358979323846264338327950288419716939937510)];
	[self _testRoot:@(DBL_MAX)];
	[self _testRoot:@(DBL_MIN)];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeDouble:0.0 forKey:@"key0"];
	[a encodeDouble:-1.0 forKey:@"key1"];
	[a encodeDouble:3.14159265358979323846264338327950288419716939937510 forKey:@"key2"];
	[a encodeDouble:DBL_MAX forKey:@"key3"];
	[a encodeDouble:DBL_MIN forKey:@"key4"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqual([u decodeDoubleForKey:@"key0"], 0.0);
	XCTAssertEqual([u decodeDoubleForKey:@"key1"], -1.0);
	XCTAssertEqual([u decodeDoubleForKey:@"key2"], 3.14159265358979323846264338327950288419716939937510);
	XCTAssertEqual([u decodeDoubleForKey:@"key3"], DBL_MAX);
	XCTAssertEqual([u decodeDoubleForKey:@"key4"], DBL_MIN);
}





	

- (void)testSize
{
	[self _testRoot:[NSValue valueWithSize:NSMakeSize(0.0, 0.0)]];
	[self _testRoot:[NSValue valueWithSize:NSMakeSize(738.1234567, 987.6543210)]];
	[self _testRoot:[NSValue valueWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MIN)]];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeSize:NSMakeSize(0.0, 0.0) forKey:@"key0"];
	[a encodeSize:NSMakeSize(738.1234567, 987.6543210) forKey:@"key1"];
	[a encodeSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MIN) forKey:@"key2"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssert(NSEqualSizes([u decodeSizeForKey:@"key0"], NSMakeSize(0.0, 0.0)));
	XCTAssert(NSEqualSizes([u decodeSizeForKey:@"key1"], NSMakeSize(738.1234567, 987.6543210)));
	XCTAssert(NSEqualSizes([u decodeSizeForKey:@"key2"], NSMakeSize(CGFLOAT_MAX, CGFLOAT_MIN)));
}





	

- (void)testPoint
{
	[self _testRoot:[NSValue valueWithPoint:NSMakePoint(0.0, 0.0)]];
	[self _testRoot:[NSValue valueWithPoint:NSMakePoint(738.1234567, 987.6543210)]];
	[self _testRoot:[NSValue valueWithPoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MIN)]];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodePoint:NSMakePoint(0.0, 0.0) forKey:@"key0"];
	[a encodePoint:NSMakePoint(738.1234567, 987.6543210) forKey:@"key1"];
	[a encodePoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MIN) forKey:@"key2"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssert(NSEqualPoints([u decodePointForKey:@"key0"], NSMakePoint(0.0, 0.0)));
	XCTAssert(NSEqualPoints([u decodePointForKey:@"key1"], NSMakePoint(738.1234567, 987.6543210)));
	XCTAssert(NSEqualPoints([u decodePointForKey:@"key2"], NSMakePoint(CGFLOAT_MAX, CGFLOAT_MIN)));
}





	

- (void)testRect
{
	[self _testRoot:[NSValue valueWithRect:NSMakeRect(0.0, 0.0, 738.1234567, 987.6543210)]];
	[self _testRoot:[NSValue valueWithRect:NSMakeRect(CGFLOAT_MIN, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MIN)]];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeRect:NSMakeRect(0.0, 0.0, 738.1234567, 987.6543210) forKey:@"key0"];
	[a encodeRect:NSMakeRect(CGFLOAT_MIN, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MIN) forKey:@"key1"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssert(NSEqualRects([u decodeRectForKey:@"key0"], NSMakeRect(0.0, 0.0, 738.1234567, 987.6543210)));
	XCTAssert(NSEqualRects([u decodeRectForKey:@"key1"], NSMakeRect(CGFLOAT_MIN, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MIN)));
}





	

- (void)testObject
{
	[self _testRoot:@""];
	[self _testRoot:@"striéng"];
	[self _testRoot:@"Iлｔêｒԉãｔｉｏԉɑｌìｚãｔí߀л"];
	[self _testRoot:NSNull.null];
	[self _testRoot:@{@"key": @"value"}];
	[self _testRoot:@[@"a", @"b", @"c", @(1), @(2), @(3)]];
	[self _testRoot:@{@"key": @(1324.5), @(5) : @[@"a", NSNull.null, [[[Foo alloc] init] autorelease]]}];
	
	NSMutableData * mdata = [NSMutableData data];
	MsgPackArchiver * a = [[MsgPackArchiver alloc] initForWritingWithMutableData:mdata];
	[a encodeObject:@"" forKey:@"key0"];
	[a encodeObject:@"striéng" forKey:@"key1"];
	[a encodeObject:@"Iлｔêｒԉãｔｉｏԉɑｌìｚãｔí߀л" forKey:@"key2"];
	[a encodeObject:NSNull.null forKey:@"key3"];
	[a encodeObject:@{@"key": @"value"} forKey:@"key4"];
	[a encodeObject:@[@"a", @"b", @"c", @(1), @(2), @(3)] forKey:@"key5"];
	[a encodeObject:@{@"key": @(1324.5), @(5) : @[@"a", NSNull.null, [[[Foo alloc] init] autorelease]]} forKey:@"key6"];
	[a finishEncoding];
	
	MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:mdata];
	XCTAssertEqualObjects([u decodeObjectForKey:@"key0"], (@""));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key1"], (@"striéng"));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key2"], (@"Iлｔêｒԉãｔｉｏԉɑｌìｚãｔí߀л"));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key3"], (NSNull.null));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key4"], (@{@"key": @"value"}));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key5"], (@[@"a", @"b", @"c", @(1), @(2), @(3)]));
	XCTAssertEqualObjects([u decodeObjectForKey:@"key6"], (@{@"key": @(1324.5), @(5) : @[@"a", NSNull.null, [[[Foo alloc] init] autorelease]]}));
}





- (void)_testRoot:(id)oldRoot
{
	NSData * data = [MsgPackArchiver archivedDataWithRootObject:oldRoot];
	XCTAssertNotNil(data);
	
	id newRoot = [MsgPackUnarchiver unarchiveObjectWithData:data];
	XCTAssertNotNil(newRoot);
	
	[self assertDeepCompare:oldRoot to:newRoot];
}



- (void)assertDeepCompare:(id)rootA to:(id)rootB
{
	// As long as each custom class we're testing properly implements -isEqual: and -hash, then this will do a full deep comparison
	// Note that we're assuming for custom classes in this testing rig, the keys encoded and decoded are also compared in -isEqual:
	// so that we're fairly testing whether the decoded value is equal to the value that was encoded.
	XCTAssert([rootA isEqual:rootB]);
}






#pragma mark -
#pragma mark Performance Test

- (void)testArchivingPerformanceNSCoder
{
	__block NSUInteger length = 0;
	
	[self measureBlock:^{
		NSMutableData * data = [NSMutableData data];
		NSKeyedArchiver * archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
		[self archiveWithCoder:archiver];
		[archiver finishEncoding];
		length = data.length;
	}];
	
	NSLog(@"NSCoder length: %lu", length);
}


- (void)testArchivingPerformanceMsgPack
{
	__block NSUInteger length = 0;
	
	[self measureBlock:^{
		NSMutableData * data = [NSMutableData data];
		MsgPackArchiver * archiver = [[[MsgPackArchiver alloc] initForWritingWithMutableData:data] autorelease];
		[self archiveWithCoder:archiver];
		[archiver finishEncoding];
		length = data.length;
	}];
	
	NSLog(@"MsgPack length: %lu", length);
}



- (void)archiveWithCoder:(NSCoder *)coder
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	NSMutableArray * intArray = [NSMutableArray array];
	NSMutableArray * strArray = [NSMutableArray array];
	NSMutableData * data = [NSMutableData data];
	
	for (int i = 0; i < 100000; i++) {
		NSString * s = [NSString stringWithFormat:@"string %d string %d string %d string %d string %d", rand(), rand(), rand(), rand(), rand()];
		[coder encodeInt:i forKey:[NSString stringWithFormat:@"int_%d", i]];
		[coder encodeObject:s forKey:[NSString stringWithFormat:@"string_%d", i]];
		[coder encodeBool:(i % 2 == 0) forKey:[NSString stringWithFormat:@"bool_%d", i]];
		[intArray addObject:@(i)];
		[strArray addObject:s];
		[dict setObject:[@[@(i), s] objectAtIndex:i % 2] forKey:[NSString stringWithFormat:@"key_%d", i]];
		[data appendBytes:(const void *)&i length:sizeof(int)];
	}
	
	[coder encodeObject:intArray forKey:@"intArray"];
	[coder encodeObject:strArray forKey:@"strArray"];
	[coder encodeBytes:data.bytes length:data.length forKey:@"bytes"];
	[coder encodeObject:data forKey:@"data"];
	[coder encodeObject:dict forKey:@"dictionary"];
}





- (void)testUnarchivingPerformanceNSCoder
{
	NSMutableData * data = [NSMutableData data];
	NSKeyedArchiver * archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
	[self archiveWithCoder:archiver];
	[archiver finishEncoding];
	
	
	[self measureBlock:^{
		NSKeyedUnarchiver * unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
		[self unarchiveWithCoder:unarchiver];
	}];
}


- (void)testUnarchivingPerformanceMsgPack
{
	NSMutableData * data = [NSMutableData data];
	MsgPackArchiver * archiver = [[[MsgPackArchiver alloc] initForWritingWithMutableData:data] autorelease];
	[self archiveWithCoder:archiver];
	[archiver finishEncoding];
	
	
	[self measureBlock:^{
		MsgPackUnarchiver * unarchiver = [[[MsgPackUnarchiver alloc] initForReadingWithData:data] autorelease];
		[self unarchiveWithCoder:unarchiver];
	}];
}



- (void)unarchiveWithCoder:(NSCoder *)coder
{
	for (int i = 0; i < 1000; i++) {
		[coder decodeIntForKey:[NSString stringWithFormat:@"int_%d", i]];
		[coder decodeObjectForKey:[NSString stringWithFormat:@"string_%d", i]];
		[coder decodeBoolForKey:[NSString stringWithFormat:@"bool_%d", i]];
	}
	
	
	[coder decodeObjectForKey:@"intArray"];
	[coder decodeObjectForKey:@"strArray"];
	[coder decodeBytesForKey:@"bytes" returnedLength:NULL];
	[coder decodeObjectForKey:@"data"];
	[coder decodeObjectForKey:@"dictionary"];
}



@end







#pragma mark -

@implementation Foo

- (id)init
{
	if ((self = [super init])) {
		self.empty = nil;
		self.null = NSNull.null;
		self.string = @"Iлｔêｒԉãｔｉｏԉɑｌìｚãｔí߀л";
		self.number = @(53.9);
		self.dictionary = @{@"this" : @"is boring"};
	}
	
	return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super init])) {
		self.empty      = [coder decodeObjectForKey:@"empty"];
		self.null       = [coder decodeObjectForKey:@"null"];
		self.string     = [coder decodeObjectForKey:@"string"];
		self.number     = [coder decodeObjectForKey:@"number"];
		self.dictionary = [coder decodeObjectForKey:@"dictionary"];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.empty      forKey:@"empty"];
	[coder encodeObject:self.null       forKey:@"null"];
	[coder encodeObject:self.string     forKey:@"string"];
	[coder encodeObject:self.number     forKey:@"number"];
	[coder encodeObject:self.dictionary forKey:@"dictionary"];
}

- (NSUInteger)hash
{
	// We don't care about performance.
	return 0;
}


- (BOOL)isEqual:(id)obj
{
	if (![obj isKindOfClass:[Foo class]]) {
		return NO;
	}
	
	return YES;
}

@end

