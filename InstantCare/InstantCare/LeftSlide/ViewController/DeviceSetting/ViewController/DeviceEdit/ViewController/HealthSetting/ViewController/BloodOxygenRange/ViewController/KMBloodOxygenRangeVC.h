//
//  KMBloodOxygenRangeVC.h
//  InstantCare
//
//  Created by km on 16/8/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMBloodOxygenModel;

@interface KMBloodOxygenRangeVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMBloodOxygenModel *model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
