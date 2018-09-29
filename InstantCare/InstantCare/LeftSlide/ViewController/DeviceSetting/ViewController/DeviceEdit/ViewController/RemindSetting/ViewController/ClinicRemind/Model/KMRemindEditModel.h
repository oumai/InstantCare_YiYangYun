//
//  KMRemindEditModel.h
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMRemindModel.h"


@interface KMRemindEditModel : NSObject


@property (nonatomic, copy) NSString *year;

@property (nonatomic, copy) NSString *mon;

@property (nonatomic, copy) NSString *day;

@property (nonatomic, copy) NSString *hour;

@property (nonatomic, copy) NSString *min;


/**
 *  开关
 */
@property(nonatomic,copy)NSString * isValid;

/**
 *  提醒内容
 */
@property(nonatomic,copy)NSString * attribute1;
/**
 *  周一
 */
@property(nonatomic,copy)NSString *  t1Hex;
/**
 *  周二
 */
@property(nonatomic,copy)NSString *  t2Hex;
/**
 *  周三
 */
@property(nonatomic,copy)NSString *  t3Hex;
/**
 *  周四
 */
@property(nonatomic,copy)NSString *  t4Hex;
/**
 *  周五
 */
@property(nonatomic,copy)NSString *  t5Hex;
/**
 *  周六
 */
@property(nonatomic,copy)NSString *  t6Hex;
/**
 *  周日
 */
@property(nonatomic,copy)NSString * t7Hex;

// 遍历构造器
-(void)setValueWithModel:(KMRemindDetailModel *)model;

@end
