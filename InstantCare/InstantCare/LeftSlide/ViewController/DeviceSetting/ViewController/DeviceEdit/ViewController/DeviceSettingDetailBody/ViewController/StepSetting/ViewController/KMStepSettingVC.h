//
//  KMStepSettingVC.h
//  InstantCare
//
//  Created by km on 16/9/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMCheckHeartRateModel;
@interface KMStepSettingVC : UIViewController
/** 数据模型 */
@property (nonatomic, strong) KMCheckHeartRateModel *model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
