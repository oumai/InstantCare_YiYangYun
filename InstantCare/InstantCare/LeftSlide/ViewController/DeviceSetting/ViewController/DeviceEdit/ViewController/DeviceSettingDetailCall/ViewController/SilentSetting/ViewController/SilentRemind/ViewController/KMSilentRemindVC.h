//
//  KMSilentRemindVC.h
//  InstantCare
//
//  Created by km on 16/9/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSilentSettingModel;
@interface KMSilentRemindVC : UITableViewController

/**
 *  设备imei号码；
 */
@property (nonatomic, copy) NSString *imei;

/** 点击的标识 */
@property (nonatomic, assign) NSInteger index;

/** 数据模型 */
@property (nonatomic, strong) KMSilentSettingModel *model;


@end
