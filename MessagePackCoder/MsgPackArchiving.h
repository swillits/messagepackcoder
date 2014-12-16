//
//  MsgPackArchiving.h
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	MsgPackArchiveTypeData = 0,
	MsgPackArchiveTypeObject,
	MsgPackArchiveTypeString,
	MsgPackArchiveTypeArray,
	MsgPackArchiveTypeDictionary,
	
	MsgPackArchiveTypeBoolean,
	MsgPackArchiveTypeUInt64,
	MsgPackArchiveTypeInt64,
	MsgPackArchiveTypeDouble,
	MsgPackArchiveTypePoint,
	MsgPackArchiveTypeSize,
	MsgPackArchiveTypeRect
} MsgPackArchiveType;
