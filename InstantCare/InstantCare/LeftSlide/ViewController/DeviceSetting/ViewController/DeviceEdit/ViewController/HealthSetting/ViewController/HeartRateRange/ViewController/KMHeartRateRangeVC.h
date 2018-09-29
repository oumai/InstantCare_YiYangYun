//
//  KMHeartRateRangeVC.h
//  InstantCare
//
//  Created by km on 16/8/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMHeartRateModel;

@interface KMHeartRateRangeVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMHeartRateModel *model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
