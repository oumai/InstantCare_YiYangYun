//
//  KMGeofenceVC.h
//  InstantCare
//
//  Created by bruce zhu on 16/8/11.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMPushMsgModel;
// 电子围栏
@interface KMGeofenceVC : UIViewController

@property (nonatomic, copy) NSString *imei;

/**
 *   便利构造器
 */
- (instancetype)initGeofenceWithModel:(KMPushMsgModel *)model;

@end
