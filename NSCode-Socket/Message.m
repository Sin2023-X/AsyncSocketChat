//
//  Message.m
//  NSCode-Socket
//
//  Created by admin on 15/11/17.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "Message.h"

@implementation Message
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_length forKey:@"length"];
    [aCoder encodeObject:_message forKey:@"message"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super init]) {
        self.length = [aDecoder decodeObjectForKey:@"length"];
        self.message = [aDecoder decodeObjectForKey:@"message"];
    }
    return self;
}
@end
