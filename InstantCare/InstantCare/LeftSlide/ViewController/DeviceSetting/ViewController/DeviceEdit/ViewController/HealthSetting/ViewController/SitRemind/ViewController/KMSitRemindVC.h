//
//  KMSitRemindVC.h
//  InstantCare
//
//  Created by km on 16/9/12.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSleepMonitorModel;

@interface KMSitRemindVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMSleepMonitorModel * model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
