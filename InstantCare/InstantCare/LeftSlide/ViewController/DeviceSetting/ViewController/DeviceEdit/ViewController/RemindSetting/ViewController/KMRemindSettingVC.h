//
//  KMRemindSettingVC.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  提醒设定(回诊提醒、吃药提醒、提醒)
 */
@interface KMRemindSettingVC : UIViewController

@property (nonatomic, copy) NSString *imei;

/**
 *  设备类型
 */
@property(nonatomic,copy)NSString *type;

@end
