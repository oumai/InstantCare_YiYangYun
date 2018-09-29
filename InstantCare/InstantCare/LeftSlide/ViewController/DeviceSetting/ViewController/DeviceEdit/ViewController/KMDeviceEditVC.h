//
//  KMDeviceEditVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/2.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMBundleDevicesModel.h"

// 设备资料编辑（头像，手表样式，名称，电话号码）
@interface KMDeviceEditVC : UIViewController

@property (nonatomic, strong) KMBundleDevicesDetailModel *detailModel;

@end
