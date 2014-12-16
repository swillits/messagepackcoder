//
//  MsgPackArchiver.h
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgPackArchiver : NSCoder
+ (NSData *)archivedDataWithRootObject:(id)rootObject;

- (instancetype)initForWritingWithMutableData:(NSMutableData *)data;
- (void)finishEncoding;

@end
