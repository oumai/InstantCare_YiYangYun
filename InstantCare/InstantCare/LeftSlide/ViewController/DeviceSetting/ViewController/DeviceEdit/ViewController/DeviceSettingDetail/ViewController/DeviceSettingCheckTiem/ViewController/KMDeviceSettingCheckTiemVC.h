//
//  KMDeviceSettingCheckTiemVC.h
//  InstantCare
//
//  Created by km on 16/8/19.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMDeviceSettingCheckTimeModel;
@interface KMDeviceSettingCheckTiemVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMDeviceSettingCheckTimeModel *model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
