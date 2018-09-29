//
//  KMFallModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/21.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  跌倒模型
 */
@interface KMFallModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end

@interface KMFallDetailModel : NSObject

@property (nonatomic, assign) long long emgDate;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) double gpsLat;

@property (nonatomic, assign) double gpsLng;

@property (nonatomic, assign) BOOL cellSelected;

@end

