//
//  KMBundleDevicesModel.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/8.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMBundleDevicesModel.h"
#import "MJExtension.h"
@implementation KMBundleDevicesModel

+ (void)load {
    [KMBundleDevicesModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMBundleDevicesDetailModel"
                 };
    }];
}

@end

@implementation KMBundleDevicesDetailModel

@end

@implementation KMBundleDevices2SeverModel

@end

@implementation KMPortraitModel

@end
