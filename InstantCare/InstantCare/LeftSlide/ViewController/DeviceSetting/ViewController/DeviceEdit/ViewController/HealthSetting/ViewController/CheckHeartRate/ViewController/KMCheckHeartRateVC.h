//
//  KMCheckHeartRateVC.h
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMCheckHeartRateModel;


@interface KMCheckHeartRateVC : UIViewController

/** 数据模型 */
@property (nonatomic, strong) KMCheckHeartRateModel *model;

/** imei */
@property (nonatomic, copy) NSString *imei;

@end
