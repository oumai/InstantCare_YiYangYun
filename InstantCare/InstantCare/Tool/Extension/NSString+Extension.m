//
//  NSString+Extension.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/17.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

/**
 *  如果字符串为空返回@""
 *
 *  @param string 原字符串
 *
 *  @return 新字符串，不会为(null)
 */
+ (NSString *)nullStringReturn:(NSString *)string
{
    if (string) return string;
    
    return @"";
}

/**
 *  转换日期格式
 *
 *  @param date 从1970开始的毫秒
 *
 *  @return yyyy-MM-dd HH:mm:ss 字符串
 */
+ (NSString *)stringWholeWithDate:(long long)date {
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:date/1000.0];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:newdate];
}

+ (NSString *)stringWholeWithDateAndMinute:(long long)date {
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:date/1000.0];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:newdate];
}

+ (NSString *)stringWithNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringWithDate:(long long)date format:(NSString *)format {
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:date/1000.0];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:newdate];
}

+ (NSString *)stringYearWithDate:(long long)date {
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:date/1000.0];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:newdate];
}

+ (NSDate *)stringYearWithDateString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter dateFromString:dateString];
}

@end
