//
//  KMLocationVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KMPushMsgModel.h"

/// 定位记录页面
@interface KMLocationVC : UIViewController
/**
 *  是否是SOS求救
 */
@property (nonatomic, strong) KMPushMsgModel *pushModel;

@end
