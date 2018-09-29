//
//  KMSleepMonitorVC.h
//  Temp
//
//  Created by km on 16/8/12.
//  Copyright © 2016年 km. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSleepMonitorModel;


@interface KMSleepMonitorVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMSleepMonitorModel * model;

/** imei */
@property (nonatomic, copy) NSString *imei;


@end
