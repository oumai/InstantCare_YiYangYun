//
//  KMDeviceSettingResModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/10.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMDeviceSettingModel.h"

@interface KMDeviceSettingResModel : NSObject

@property (nonatomic, assign) int status;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) KMDeviceSettingModel *content;

@end
