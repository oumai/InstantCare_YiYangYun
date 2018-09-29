//
// Created by Jörg Polakowski on 14/12/13.
// Copyright (c) 2013 kevinzhow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PNLineChartDataItem : NSObject

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y;
+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y andRawY:(CGFloat)rawY;

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y pointColor:(UIColor *)pointColor;

@property (readonly) CGFloat y; // should be within the y range
@property (readonly) CGFloat rawY; // this is the raw value, used for point label.

/**
 *  画点的颜色
 */
@property (nonatomic, strong) UIColor *pointColor;

@end
