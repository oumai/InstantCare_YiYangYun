//
//  KMClinicRemindDetailVC.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMRemindModel.h"


/**
 *  回诊提醒设定
 */
@interface KMClinicRemindDetailVC : UIViewController

@property (nonatomic, copy) NSString *imei;
/**
 *  代码复用: clinic, medical
 */
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) KMRemindModel *remindModel;
@property (nonatomic, assign) int sequence;

@end
