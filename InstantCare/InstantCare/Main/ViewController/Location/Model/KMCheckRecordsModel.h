//
//  KMCheckRecordsModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  打卡记录数据模型
 */
@interface KMCheckRecordsModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end


@interface KMCheckRecordsDetailModel : NSObject

@property (nonatomic, copy) NSString *batchDetailKey;

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long long checkInDate;

@property (nonatomic, assign) long long checkOutDate;

@property (nonatomic, assign) int val;

@property (nonatomic, copy) NSString *inGpsNsLat;

@property (nonatomic, assign) double inGpsLat;

@property (nonatomic, copy) NSString *inGpsEwLng;

@property (nonatomic, assign) double inGpsLng;

@property (nonatomic, copy) NSString *inAddress;

@property (nonatomic, copy) NSString *inLocStatus;

@property (nonatomic, copy) NSString *inIsvalid;

@property (nonatomic, assign) int inHpe;

@property (nonatomic, copy) NSString *outGpsNsLat;

@property (nonatomic, assign) double outGpsLat;

@property (nonatomic, copy) NSString *outGpsEwLng;

@property (nonatomic, assign) double outGpsLng;

@property (nonatomic, copy) NSString *outAddress;

@property (nonatomic, copy) NSString *outLocStatus;

@property (nonatomic, copy) NSString *outIsvalid;

@property (nonatomic, assign) int outHpe;

@property (nonatomic, assign) long long createDate;

@property (nonatomic, assign) long long updateDate;

/**
 *  程序内部使用: 按钮选中的状态
 *  -1 -> 左右两个按钮都没有选
 *  0  -> 左边选中状态
 *  1  -> 右边选中状态
 */
@property (nonatomic, assign) NSInteger btnSelectState;

@end