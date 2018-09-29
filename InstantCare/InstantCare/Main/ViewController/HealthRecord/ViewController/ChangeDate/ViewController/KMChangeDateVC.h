//
//  KMChangeDateVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/15.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KMChangeDateDelegate <NSObject>

@optional
- (void)changeDateComplete:(NSDate *)startDate
                   endDate:(NSDate *)endDate
                     Index:(NSInteger)index;

@end

/**
 *  更改测量区间日期
 */
@interface KMChangeDateVC : UIViewController

@property (nonatomic, weak) id<KMChangeDateDelegate> delegate;

/**
 *  开始日期
 */
@property (nonatomic, strong) NSDate *startDate;
/**
 *  结束日期
 */
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, assign) NSInteger currentIndex;

@end
