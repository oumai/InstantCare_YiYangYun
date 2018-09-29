//
//  KMChangeSingleDateVCViewController.h
//  InstantCare
//
//  Created by Frank He on 9/9/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KMChangeSingleDateDelegate <NSObject>

@optional
- (void)changeDateComplete:(NSDate *)currentDate
                     Index:(NSInteger)index;

@end

@interface KMChangeSingleDateVC : UIViewController

@property (nonatomic, weak) id<KMChangeSingleDateDelegate> delegate;

/**
 *  选择时间
 */
@property (nonatomic, strong) NSDate *chooseDate;

@property (nonatomic, assign) NSInteger currentIndex;

@end
