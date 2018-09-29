//
//  KMSleepQAModel.h
//  InstantCare
//
//  Created by Frank He on 9/1/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMSleepQAModel : NSObject

//入睡时间
@property (nonatomic, copy) NSString* startSleepTime;

//起床时间
@property (nonatomic, copy) NSString* getUpTime;

//睡眠总时间
@property (nonatomic,copy) NSString* duration;

//安静睡眠的百分比
@property (nonatomic,assign) long long quietSleepPercent;

//深入睡眠的百分比
@property (nonatomic,assign) long long deepSleepPercent;

//最大心率
@property (nonatomic,assign) long long maxHeartRate;

//最小心率
@property (nonatomic,assign) long long minHeartRate;

//平均心率
@property (nonatomic,assign) long long avgHeartRate;

//活动情况
@property (nonatomic,copy) NSString* sleepActiveStateList;

//心率情况
@property (nonatomic,copy) NSString* sleepHeartRateStateList;

//活动次数
@property (nonatomic,assign) NSInteger activeCount;

//活动时间
@property (nonatomic,copy) NSString* activeTime;

//前7天的平均睡眠时间
@property (nonatomic,copy) NSString* beforeSevenDayAVGSleepTime;

//前7天的平均睡眠质量
@property (nonatomic,assign) long long beforeSevenDayAVGSleepQuality;

//当天的睡眠质量
@property (nonatomic,assign) long long todayQualityPercent;

//睡眠质量表
@property (nonatomic,strong) NSArray* sleepQulityPercentList;

//采集时间 seconds
@property (nonatomic, assign) long long collectTime;

-(NSString*)durationTime;

-(NSString*)quietSleepTotalTime;

-(NSString*)deepSleepTotalTime;

-(NSString*)lastCollectTime;

-(NSArray*)sleepQulityTimes;

//睡眠状态列表
@property(nonatomic,strong)NSMutableArray* sleepQulityStates;

@end
