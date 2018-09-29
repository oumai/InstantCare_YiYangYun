//
//  KMBindDeviceListVC.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/23.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMBundleDevicesModel.h"

@protocol KMBindDeviceListVCDelegate <NSObject>

@optional
- (void)didSelectBindDeviceWithModel:(KMBundleDevicesDetailModel *)deviceListDetailModel;

@end

@interface KMBindDeviceListVC : UIViewController

@property (nonatomic, weak) id<KMBindDeviceListVCDelegate> delegate;

@property (nonatomic, strong) KMBundleDevicesDetailModel *detailModel;

@end
