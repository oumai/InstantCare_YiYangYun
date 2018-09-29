//
//  KMDeviceSettingModel.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/10.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingModel.h"
#import "MJExtension.h"

@implementation KMDeviceManagerModel

+ (void)load {
    [KMDeviceManagerModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMDeviceManagerDetailModel"
                 };
    }];
}

@end

@implementation KMDeviceManagerDetailModel

@end

@implementation KMDeviceSettingModel

@end


@implementation KMDeviceSettingDetailCallModel

@end

@implementation KMDeviceSettingCallFamilyModel

@end
@implementation KMDeviceSettingCallSosModel

@end
@implementation KMDeviceSettingCallSosSmsModel

@end


@implementation KMDeviceSettingPhysiqueModel

@end



@implementation KMDeviceSettingCheckTimeModel


@end









