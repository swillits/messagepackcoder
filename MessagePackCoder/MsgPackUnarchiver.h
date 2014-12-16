//
//  MsgPackUnarchiver.h
//  MessagePackCoder
//  https://github.com/swillits/messagepackcoder
//
//  Created by Seth Willits on 12/4/14.
//  Copyright (c) 2014 Seth Willits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgPackUnarchiver : NSCoder
+ (id)unarchiveObjectWithData:(NSData *)data;

- (instancetype)initForReadingWithData:(NSData *)data;

@end
