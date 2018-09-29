//
//  KMValModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  打卡点数
 */
@interface KMValModel : NSObject
/**
 *  类型：KMValDetailModel
 */
@property (nonatomic, strong) NSArray *list;

@end

@interface KMValDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *imsi;

@property (nonatomic, copy) NSString *batchDetailKey;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) int currentVal;

@property (nonatomic, assign) int onLineStatus;

@property (nonatomic, assign) long long createDate;

@property (nonatomic, assign) long long updateDate;

@end

