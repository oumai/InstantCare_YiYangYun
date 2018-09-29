//
//  KMGeofenceModel.h
//  InstantCare
//
//  Created by bruce zhu on 16/8/12.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 电子围栏模型
@interface KMGeofenceModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *fenceName;

@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) double latitude;

@property (nonatomic, copy) NSString *starttime;

@property (nonatomic, copy) NSString *endtime;

@property (nonatomic, assign) int enable;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) int radius;

@property (nonatomic, assign) long long updatetime;

@property (nonatomic, assign) long long createtime;

@property (nonatomic, assign) int interval;

@end
