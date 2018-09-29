//
//  KMLocationService.h
//  InstantCare
//
//  Created by Frank He on 9/27/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMLocationService : NSObject

+ (instancetype)sharedInstance;

/**
 *  获取打卡点数
 *
 *  @param imei  IMEI
 *  param block 结果返回block
 */
- (void)getValWithIMEI:(NSString *)imei
        successHandler:(void (^)(id data))success
        failureHandler:(void (^)(NSError *error))failure;
/**
 *  获取打卡记录
 *
 *  @param imei  IMEI
 *  param block 结果返回block
 */
- (void)getCheckRecordsWithIMEI:(NSString *)imei startInt:(NSInteger)startInt endInt:(NSInteger)endInt successHandler:(void (^)(id data))success failureHandler:(void (^)(NSError *error))failure;

/**
 *  获取历史记录
 *
 *  @param imei  IMEI
 *  param block
 */

- (void)getHisRecordsWithIMEI:(NSString *)imei startInt:(NSInteger)startInt endInt:(NSInteger)endInt successHandler:(void (^)(id data))success failureHandler:(void (^)(NSError *error))failure;
//- (void)getHisRecordsWithIMEI:(NSString *)imei
//               successHandler:(void (^)(id data))success
//               failureHandler:(void (^)(NSError *error))failure;

/**
 *  获取紧急救援记录
 *
 *  @param imei  IMEI
 *  param block
 */
- (void)getEmgRecordsWithIMEI:(NSString *)imei startInt:(NSInteger)startInt endInt:(NSInteger)endInt successHandler:(void (^)(id data))success failureHandler:(void (^)(NSError *error))failure;

@end
