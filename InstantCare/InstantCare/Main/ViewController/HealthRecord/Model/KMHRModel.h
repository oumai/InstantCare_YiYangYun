//
//  KMHRModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMHRModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end

@interface KMHRDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long heartRate;
/**
 *  服务器返回的字段有问题，需要APP判断：如果bsTime为空，就取createDate
 */
@property (nonatomic, assign) long long bsTime;

@property (nonatomic, assign) long long createDate;

@end
