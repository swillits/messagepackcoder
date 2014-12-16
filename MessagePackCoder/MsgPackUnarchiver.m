//
//  MsgPackUnarchiver.m
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <objc/runtime.h>
#import "MsgPackUnarchiver.h"
#import "MsgPackArchiving.h"
#import "cmp.h"


#define OBJ_FOR_KEY(key) \
		[_decodedObjects objectForKey:key]

#define UNPACK_TYPE(outType) MsgPackUnarchiver_UnpackType(self, outType)

#define UNPACK(ctx__, type__, variable__, msg__) \
	if (!cmp_read_ ## type__ (&ctx__, &variable__)) { \
		[NSException raise:NSInternalInconsistencyException format:@"MsgPackUnarchiver: Couldn't unpack %@ because %s", msg__, cmp_strerror(&ctx__)]; \
	}



static bool MsgPackUnarchiver_reader(struct cmp_ctx_s *ctx, void *data, size_t limit);



@implementation MsgPackUnarchiver
{
	cmp_ctx_t _ctx;
	NSData * _data;
	
	const void * _dataBytes;
	size_t _dataLength;
	
	unsigned long long _readOffset;
	NSMutableDictionary * _decodedObjects;
}




+ (id)unarchiveObjectWithData:(NSData *)data
{
	id root = nil;
	
	@autoreleasepool {
		MsgPackUnarchiver * u = [[MsgPackUnarchiver alloc] initForReadingWithData:data];
		root = [[u decodeObjectForKey:@"ROOT"] retain];
		[u release];
	}
	
	return [root autorelease];
}



- (instancetype)initForReadingWithData:(NSData *)data;
{
	if (!(self = [super init])) {
		return nil;
	}
	
	_data = [data retain];
	_dataBytes = _data.bytes;
	_dataLength = _data.length;
	_decodedObjects = [[NSMutableDictionary alloc] init];
	
	
	cmp_init(&_ctx, (void *)self, MsgPackUnarchiver_reader, NULL);
	
	while ((self->_readOffset < self->_dataLength)) {
		@autoreleasepool {
			NSString * key = [self unpackString];
			id obj = [self _unpackTypeAndObject];
			[_decodedObjects setObject:obj forKey:key];
		}
	}
	
	return self;
}



- (void)dealloc
{
	[_decodedObjects release];
	[_data release];
	[super dealloc];
}







#pragma mark -
#pragma mark Required For All Coders

- (void)decodeValueOfObjCType:(const char *)type at:(void *)data;
{
	[self doesNotRecognizeSelector:_cmd];
}



- (NSData *)decodeDataObject;
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}






#pragma mark -
#pragma mark Required for Key Coding

- (BOOL)allowsKeyedCoding
{
	return YES;
}



- (BOOL)containsValueForKey:(NSString *)key;
{
	return (OBJ_FOR_KEY(key) != nil);
}



- (id)decodeObjectForKey:(NSString *)key;
{
	return OBJ_FOR_KEY(key);
}



- (BOOL)decodeBoolForKey:(NSString *)key;
{
	return [OBJ_FOR_KEY(key) boolValue];
}



- (int)decodeIntForKey:(NSString *)key;
{
	return [OBJ_FOR_KEY(key) intValue];
}



- (int32_t)decodeInt32ForKey:(NSString *)key;
{
	return (int32_t)[OBJ_FOR_KEY(key) longValue];
}



- (int64_t)decodeInt64ForKey:(NSString *)key;
{
	return (int64_t)[OBJ_FOR_KEY(key) longLongValue];
}



- (NSInteger)decodeIntegerForKey:(NSString *)key;
{
	return (NSInteger)[OBJ_FOR_KEY(key) integerValue];
}



- (float)decodeFloatForKey:(NSString *)key;
{
	return (float)[OBJ_FOR_KEY(key) floatValue];
}



- (double)decodeDoubleForKey:(NSString *)key;
{
	return (double)[OBJ_FOR_KEY(key) doubleValue];
}



- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp;
{
	NSData * data = OBJ_FOR_KEY(key);
	if (lengthp) *lengthp = data.length;
	return data.bytes;
}



- (NSPoint)decodePointForKey:(NSString *)key
{
	return [OBJ_FOR_KEY(key) pointValue];
}



- (NSSize)decodeSizeForKey:(NSString *)key
{
	return [OBJ_FOR_KEY(key) sizeValue];
}



- (NSRect)decodeRectForKey:(NSString *)key
{
	return [OBJ_FOR_KEY(key) rectValue];
}




#pragma mark -

bool MsgPackUnarchiver_reader(struct cmp_ctx_s *ctx, void * data, size_t limit)
{
	MsgPackUnarchiver * self = (MsgPackUnarchiver *)ctx->buf;
	if (self->_readOffset + limit <= self->_dataLength) {
		memcpy(data, self->_dataBytes + self->_readOffset, limit);
		self->_readOffset += limit;
		return true;
	}
	return false;
}



static inline BOOL MsgPackUnarchiver_UnpackType(MsgPackUnarchiver * self, MsgPackArchiveType * outType)
{
	// EOF
	if (self->_readOffset >= self->_dataLength) {
		return NO;
	}
	
	// Type
	int16_t type;
	UNPACK(self->_ctx, short, type, @"property type")
	*outType = (MsgPackArchiveType)type;
	
	return YES;
}



BOOL MsgPackUnarchiver_unpackRawBytes(MsgPackUnarchiver * self, const void ** outPtr, uint32_t * outLength)
{
	if (!cmp_read_bin_size(&self->_ctx, outLength)) {
		[NSException raise:@"Couldn't unpack raw data because there was no message" format:@"Blah blah blah"];
		return NO;
	}
	
	*outPtr = self->_dataBytes + self->_readOffset;
	self->_readOffset += *outLength;
	
	return YES;
}




- (id)_unpackTypeAndObject
{
	MsgPackArchiveType type;
	id object = nil;
	
	UNPACK_TYPE(&type);
	
	switch (type) {
		case MsgPackArchiveTypeData: {
			uint32_t length = 0;
			
			if (!cmp_read_bin_size(&_ctx, &length)) {
				[NSException raise:@"Couldn't unpack raw data because there was no message" format:@"Blah blah blah"];
				return nil;
			}
			
			NSData * data = [_data subdataWithRange:NSMakeRange(_readOffset, length)];
			_readOffset += length;
			
			object = data;
			break;
		}
		
		case MsgPackArchiveTypeObject:
			object = [self unpackObject];
			break;
		
		case MsgPackArchiveTypeString:
			object = [self unpackString];
			break;
			
		case MsgPackArchiveTypeArray:
			object = [self unpackArray];
			break;
			
		case MsgPackArchiveTypeDictionary:
			object = [self unpackDictionary];
			break;
			
		case MsgPackArchiveTypeBoolean: {
			bool value;
			UNPACK(_ctx, bool, value, @"boolean");
			object = @(value);
			break;
		}
			
		case MsgPackArchiveTypeUInt64: {
			uint64_t value;
			UNPACK(_ctx, u64, value, @"unsigned integer");
			object = @(value);
			break;
		}
			
		case MsgPackArchiveTypeInt64: {
			int64_t value;
			UNPACK(_ctx, s64, value, @"signed integer");
			object = @(value);
			break;
		}
			
		case MsgPackArchiveTypeDouble: {
			double value;
			UNPACK(_ctx, double, value, @"double");
			object = @(value);
			break;
		}
			
		case MsgPackArchiveTypePoint: {
			NSPoint p;
			UNPACK(_ctx, double, p.x, @"double");
			UNPACK(_ctx, double, p.y, @"double");
			object = [NSValue valueWithPoint:p];
			break;
		}
			
		case MsgPackArchiveTypeSize: {
			NSSize size;
			UNPACK(_ctx, double, size.width, @"double");
			UNPACK(_ctx, double, size.height, @"double");
			object = [NSValue valueWithSize:size];
			break;
		}
			
		case MsgPackArchiveTypeRect: {
			NSRect rect;
			UNPACK(_ctx, double, rect.origin.x, @"double");
			UNPACK(_ctx, double, rect.origin.y, @"double");
			UNPACK(_ctx, double, rect.size.width, @"double");
			UNPACK(_ctx, double, rect.size.height, @"double");
			object = [NSValue valueWithRect:rect];
			break;
		}
	}
	
	
	return object;
}



- (NSString *)unpackString
{
	const void * bytes = NULL;
	uint32_t length = 0;
	
	if (!MsgPackUnarchiver_unpackRawBytes(self, &bytes, &length)) {
		return nil;
	}
	
	return [[[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding] autorelease];
}



- (NSArray *)unpackArray
{
	NSMutableArray * array = [NSMutableArray array];
	uint64_t count;
	
	// Number of items in the array
	UNPACK(_ctx, u64, count, @"array count");
	
	// Unpack each item
	for (uint64_t i = 0; i < count; i++) {
		id element = [self _unpackTypeAndObject];
		[array addObject:element];
	}
	
	
	return [[array copy] autorelease];
}



- (NSDictionary *)unpackDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	uint64_t count;
	
	// Number of items in the dictionary
	UNPACK(_ctx, u64, count, @"dictionary count");
	
	// Unpack each item
	for (uint64_t i = 0; i < count; i++) {
		id key = [self _unpackTypeAndObject];
		id value = [self _unpackTypeAndObject];
		[dictionary setObject:value forKey:key];
	}
	
	return [[dictionary copy] autorelease];
}




- (id)unpackObject
{
	// Class name
	Class class;
	{
		const void * bytes = NULL; // INCLUDES THE NULL BYTE
		uint32_t length = 0;
		if (!MsgPackUnarchiver_unpackRawBytes(self, &bytes, &length)) {
			return nil;
		}
		
		class = objc_getClass((const char *)bytes);
		if (!class) {
			return nil;
		}
	}
	
	
	// Object Data
	NSData * data = nil;
	{
		uint32_t length = 0;
		
		if (!cmp_read_bin_size(&_ctx, &length)) {
			[NSException raise:@"Couldn't unpack raw data because there was no message" format:@"Blah blah blah"];
			return nil;
		}
		
		data = [NSData dataWithBytesNoCopy:(void *)(_dataBytes + _readOffset) length:length freeWhenDone:NO];
		_readOffset += length;
	}
	
	
	// Unarchive the object
	id object = nil;
	@autoreleasepool {
		MsgPackUnarchiver * coder = [[MsgPackUnarchiver alloc] initForReadingWithData:data];
		object = [[class alloc] initWithCoder:coder];
		[coder release];
	}
	
	return [object autorelease];
}


@end
