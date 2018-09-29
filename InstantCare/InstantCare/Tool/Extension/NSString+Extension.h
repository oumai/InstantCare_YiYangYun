//
//  NSString+Extension.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/17.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

+ (NSString *)nullStringReturn:(NSString *)string;

/**
 *  转换日期格式
 *
 *  @param date 从1970开始的毫秒
 *
 *  @return yyyy-MM-dd HH:mm:ss 字符串
 */
+ (NSString *)stringWholeWithDate:(long long)date;

+ (NSString *)stringWholeWithDateAndMinute:(long long)date;

+ (NSString *)stringWithNSDate:(NSDate *)date;

+ (NSString *)stringWithDate:(long long)date format:(NSString *)format;

+ (NSString *)stringYearWithDate:(long long)date;

+ (NSDate *)stringYearWithDateString:(NSString *)dateString;

@end
