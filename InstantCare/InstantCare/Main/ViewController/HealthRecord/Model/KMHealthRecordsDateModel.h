//
//  KMHealthRecordsDateModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/7.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMHealthRecordsDateModel : NSObject

// 血压
@property (nonatomic, strong) NSDate *bpStartDate;
@property (nonatomic, strong) NSDate *bpEndDate;

// 血糖
@property (nonatomic, strong) NSDate *bsStartDate;
@property (nonatomic, strong) NSDate *bsEndDate;

// 心率
@property (nonatomic, strong) NSDate *hrStartDate;
@property (nonatomic, strong) NSDate *hrEndDate;

// 计步
@property (nonatomic, strong) NSDate *stepStartDate;
@property (nonatomic, strong) NSDate *stepEndDate;

// 血氧
@property (nonatomic, strong) NSDate *boStartDate;
@property (nonatomic, strong) NSDate *boEndDate;

//睡眠质量分析
@property (nonatomic, strong) NSDate *sleepDate;

@end
