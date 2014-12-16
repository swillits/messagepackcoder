//
//  MsgPackArchiver.m
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <objc/runtime.h>
#import "MsgPackArchiver.h"
#import "MsgPackArchiving.h"
#import "cmp.h"



#define PACK_KEY_AND_TYPE(key, type)  MsgPackArchiver_PackKeyAndType(self, key, type)

#define PACK_KEY(key)  MsgPackArchiver_PackKey(self, key)
#define PACK_TYPE(type)  MsgPackArchiver_PackType(self, type)

#define PACK_STRING(ctx__, value__) \
		{ \
			const char * str = (value__).UTF8String; \
			size_t len = strlen(str); \
			cmp_write_bin(&ctx__, str, (uint32_t)len); \
		}


#define PACK_DATA(ctx__, value__) \
		cmp_write_bin(&ctx__, value__.bytes, (uint32_t)(value__).length);



static size_t MsgPackArchiver_writer(struct cmp_ctx_s *ctx, const void *data, size_t count);





@implementation MsgPackArchiver
{
	cmp_ctx_t _ctx;
	NSMutableData * _data;
	NSMutableSet * _encodedKeys;
}



+ (NSData *)archivedDataWithRootObject:(id)rootObject;
{
	MsgPackArchiver * a = [[MsgPackArchiver alloc] init];
	NSData * data = nil;
	
	[a encodeObject:rootObject forKey:@"ROOT"];
	data = [a archivedData];
	[a release];
	
	return data;
}



- (instancetype)init
{
	return [self initForWritingWithMutableData:[[[NSMutableData alloc] init] autorelease]];
}



- (instancetype)initForWritingWithMutableData:(NSMutableData *)data;
{
	if (!(self = [super init])) {
		return nil;
	}
	
	assert(data);
	_data = [data retain];
	cmp_init(&_ctx, (void *)self, NULL, MsgPackArchiver_writer);
	
	return self;
}



- (void)dealloc
{
	[_encodedKeys release];
	[_data release];
	[super dealloc];
}



- (void)finishEncoding
{
	
}



- (NSData *)archivedData
{
	
	return [[_data copy] autorelease];
}




#pragma mark -
#pragma mark Required For All Coders

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
	[self doesNotRecognizeSelector:_cmd];
}



- (void)encodeDataObject:(NSData *)data;
{
	[self doesNotRecognizeSelector:_cmd];
}






#pragma mark -
#pragma mark Required for Key Coding

- (BOOL)allowsKeyedCoding
{
	return YES;
}



- (BOOL)containsValueForKey:(NSString *)key;
{
	return [_encodedKeys containsObject:key];
}




- (void)encodeObject:(id)obj forKey:(NSString *)key;
{
	if (!obj) return;
	if (!key) [NSException raise:@"Key is nil" format:@"Blah blah blah"];
	
	PACK_KEY(key);
	[self _encodeObject:obj];
}



// Packs the object Type, and then the data. No key
- (void)_encodeObject:(id)obj
{
	if (!obj) return;
	
	if ([obj isKindOfClass:[NSNumber class]]) {
		NSNumber * num = obj;
		switch (num.objCType[0]) {
			case 'c': // char (aka BOOL)
				PACK_TYPE(MsgPackArchiveTypeBoolean);
				cmp_write_bool(&_ctx, [(NSNumber *)obj boolValue]);
				break;
				
			case 'i': // int
			case 's': // short
			case 'l': // long (32 bit)
			case 'q': // long long
				PACK_TYPE(MsgPackArchiveTypeInt64);
				cmp_write_s64(&_ctx, [(NSNumber *)obj longLongValue]);
				break;
				
			case 'I': // unsigned int
			case 'S': // unsigned short
			case 'L': // unsigned long
			case 'Q': // unsigned long long
				PACK_TYPE(MsgPackArchiveTypeInt64);
				cmp_write_s64(&_ctx, [(NSNumber *)obj longLongValue]);
				break;
				
			case 'f': // float
			case 'd': // double
				PACK_TYPE(MsgPackArchiveTypeDouble);
				cmp_write_double(&_ctx, [(NSNumber *)obj doubleValue]);
				break;
			default:
				[NSException raise:NSInvalidArgumentException format:@"Unhandled NSNumber objCType <%s> in MsgPackArchiver _encodeObject:", num.objCType];
				break;
		}
		
		
	} else if ([obj isKindOfClass:[NSString class]]) {
		PACK_TYPE(MsgPackArchiveTypeString);
		PACK_STRING(_ctx, (NSString *)obj);
		
	} else if ([obj isKindOfClass:[NSArray class]]) {
		NSArray * array = obj;
		
		PACK_TYPE(MsgPackArchiveTypeArray);
		cmp_write_u64(&_ctx, array.count);
		
		for (id elem in array) {
			[self _encodeObject:elem];
		}
		
	} else if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary * dictionary = obj;
		
		PACK_TYPE(MsgPackArchiveTypeDictionary);
		cmp_write_u64(&_ctx, dictionary.count);
		
		for (id key in dictionary.allKeys) {
			[self _encodeObject:key];
			[self _encodeObject:[dictionary objectForKey:key]];
		}
		
	} else if ([obj conformsToProtocol:@protocol(NSCoding)]) {
		PACK_TYPE(MsgPackArchiveTypeObject);
		
		const char * str = class_getName([obj class]);
		size_t len = strlen(str) + 1; // INCLUDING NULL BYTE
		cmp_write_bin(&_ctx, str, (uint32_t)len);
		{
			MsgPackArchiver * encoder = [[MsgPackArchiver alloc] init];
			NSData * data = nil;
			
			[obj encodeWithCoder:encoder];
			data = [encoder archivedData];
			[encoder release];
			
			PACK_DATA(_ctx, data);
		}
		
	} else {
		[NSException raise:@"Object does not conform to NSCoding protocol." format:@"Blah blah blah"];
	}
}




- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key;
{
	[self doesNotRecognizeSelector:_cmd];
}



- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeBoolean);
	cmp_write_bool(&_ctx, boolv);
}



- (void)encodeInt:(int)intv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeInt64);
	cmp_write_s64(&_ctx, (int64_t)intv);
}



- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeInt64);
	cmp_write_s64(&_ctx, (int64_t)intv);
}



- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeInt64);
	cmp_write_s64(&_ctx, (int64_t)intv);
}



- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeInt64);
	cmp_write_s64(&_ctx, (int64_t)intv);
}



- (void)encodeFloat:(float)realv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeDouble);
	cmp_write_double(&_ctx, (double)realv);
}



- (void)encodeDouble:(double)realv forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeDouble);
	cmp_write_double(&_ctx, (double)realv);
}



- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)len forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeData);
	cmp_write_bin(&_ctx, bytes, (uint32_t)len);
}



- (void)encodePoint:(NSPoint)point forKey:(NSString *)key
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypePoint);
	cmp_write_double(&_ctx, (double)point.x);
	cmp_write_double(&_ctx, (double)point.y);
}


- (void)encodeSize:(NSSize)size forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeSize);
	cmp_write_double(&_ctx, (double)size.width);
	cmp_write_double(&_ctx, (double)size.height);
}


- (void)encodeRect:(NSRect)rect forKey:(NSString *)key;
{
	PACK_KEY_AND_TYPE(key, MsgPackArchiveTypeRect);
	cmp_write_double(&_ctx, (double)rect.origin.x);
	cmp_write_double(&_ctx, (double)rect.origin.y);
	cmp_write_double(&_ctx, (double)rect.size.width);
	cmp_write_double(&_ctx, (double)rect.size.height);
}







#pragma mark -

void MsgPackArchiver_PackKeyAndType(MsgPackArchiver * self, NSString * key, MsgPackArchiveType type)
{
	MsgPackArchiver_PackKey(self, key);
	MsgPackArchiver_PackType(self, type);
}


void MsgPackArchiver_PackKey(MsgPackArchiver * self, NSString * key)
{
	[self->_encodedKeys addObject:key];
	
	
	const char * str = key.UTF8String;
	size_t len = strlen(str); // + 1; // Includes NULL byte
	cmp_write_bin(&self->_ctx, str, (uint32_t)len);
}


void MsgPackArchiver_PackType(MsgPackArchiver * self, MsgPackArchiveType type)
{
	cmp_write_s16(&self->_ctx, (unsigned short)type);
}


size_t MsgPackArchiver_writer(struct cmp_ctx_s *ctx, const void *data, size_t count)
{
	MsgPackArchiver * self = (MsgPackArchiver *)ctx->buf;
	[self->_data appendBytes:data length:count];
	return count;
}


@end
