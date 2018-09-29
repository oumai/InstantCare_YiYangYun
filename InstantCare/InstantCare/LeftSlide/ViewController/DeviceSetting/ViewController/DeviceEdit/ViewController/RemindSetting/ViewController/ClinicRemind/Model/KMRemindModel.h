//
//  KMRemindModel.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/22.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMRemindModel : NSObject

@property (nonatomic, assign) int enable;

@property (nonatomic, assign) int repeat;

@property (nonatomic, assign) int sequence;

@property (nonatomic, assign) int type;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) long long remindTime;

@property (nonatomic, assign) long long updateTime;

//---------- New Model -----------

@property (nonatomic, strong) NSArray *list;

@end

@interface KMRemindDetailModel : NSObject

@property (nonatomic, copy) NSString *sImei;
@property (nonatomic, copy) NSString *sTeam;
/**
 *  Y/N
 */
@property (nonatomic, copy) NSString *isvalid;

@property (nonatomic, copy) NSString *sYear;

@property (nonatomic, copy) NSString *sMon;

@property (nonatomic, copy) NSString *sDay;

@property (nonatomic, copy) NSString *sHour;

@property (nonatomic, copy) NSString *sMin;
/**
 *  1吃藥 2回診 4自定義
 */
@property (nonatomic, copy) NSString *sType;
/**
 *  提醒的内容
 */
@property (nonatomic, copy) NSString *attribute1;

@property (nonatomic, copy) NSString *t1Hex;

@property (nonatomic, copy) NSString *t2Hex;

@property (nonatomic, copy) NSString *t3Hex;

@property (nonatomic, copy) NSString *t4Hex;

@property (nonatomic, copy) NSString *t5Hex;

@property (nonatomic, copy) NSString *t6Hex;

@property (nonatomic, copy) NSString *t7Hex;

@end



