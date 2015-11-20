//
//  NSDate+FromString.m
//  AsyncSocketChat
//
//  Created by admin on 15/11/13.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "NSDate+FromString.h"

@implementation NSDate (FromString)
+ (NSString *)convertDateFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *d = [formatter stringFromDate:date];
    return d;
}
@end
