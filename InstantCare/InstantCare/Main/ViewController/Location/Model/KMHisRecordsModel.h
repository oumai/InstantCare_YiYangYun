//
//  KMHisRecordsModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMHisRecordsDetailModel : NSObject

@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) long long prDate;

@property (nonatomic, assign) double gpsLat;

@property (nonatomic, assign) double gpsLng;

@property (nonatomic, copy) NSString *locType;

/**
 *  程序内部使用
 */
@property (nonatomic, assign) BOOL cellSelected;

@end
/**
 *  历史记录
 */
@interface KMHisRecordsModel : NSObject

@property (nonatomic, strong) NSArray<KMHisRecordsDetailModel *> *list;

@end



