//
//  Message.h
//  NSCode-Socket
//
//  Created by admin on 15/11/17.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject<NSCoding>
@property (nonatomic,copy)NSString *length;
@property (nonatomic,copy)NSString *message;
@end
