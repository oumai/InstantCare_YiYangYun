//
//  KMBPModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/14.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBPModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end

@interface KMBPDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long long bpTime;

@property (nonatomic, assign) long hPressure;

@property (nonatomic, assign) long lPressure;

@property (nonatomic, assign) long puls;

@end

