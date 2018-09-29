//
//  KMSleepQAModel.m
//  InstantCare
//
//  Created by Frank He on 9/1/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMSleepQAModel.h"
#import "MJExtension.h"
@implementation KMSleepQAModel

+ (void)load {
    [KMSleepQAModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"startSleepTime" : @"startTime",
                 @"getUpTime" : @"endTime",
                 @"duration":@"duration",
                 @"quietSleepPercent" : @"quietPercent",
                 @"deepSleepPercent" : @"heartPercent",
                 @"maxHeartRate" : @"maxHeart",
                 @"minHeartRate" : @"minHeart",
                 @"avgHeartRate":@"meanHeart",
                 @"sleepActiveStateList":@"gcount",
                 @"sleepHeartRateStateList":@"hcount",
                 @"activeCount":@"activeCount",
                 @"activeTime":@"activeTime",
                 @"beforeSevenDayAVGSleepTime":@"beforeSevenDayAVGSleepTime",
                 @"beforeSevenDayAVGSleepQuality":@"beforeSevenDayAVGSleepQuality",
                 @"todayQualityPercent":@"qualityPercent",
                 @"sleepQulityPercentList":@"sleepQulityPercentList",
                 @"collectTime":@"timen"
                 };
    }];
}

-(NSString*)durationTime{
    NSArray* array = [_duration componentsSeparatedByString:@":"];
    NSString* stringTime = [NSString stringWithFormat:@"%@%d %@ %d %@",kLoadStringWithKey(@"HealthRecord_VC_sleepTotalTime"),
                            [array.firstObject intValue],
                            kLoadStringWithKey(@"HealthRecord_VC_sleepHour"),
                            [array.lastObject intValue],
                            kLoadStringWithKey(@"HealthRecord_VC_sleepMin")];
    return stringTime;
}



-(NSString*)quietSleepTotalTime{
    
    NSArray* array = [_duration componentsSeparatedByString:@":"];
    NSInteger hour = [array.firstObject intValue];
    NSInteger minute = [array.lastObject intValue];
    
    NSInteger totalSeconds = hour*60*60 + minute*60;
    
    NSTimeInterval quietSleepSeconds = totalSeconds * (_quietSleepPercent/100.0);
    
    NSInteger quietSleepHour = (int)(quietSleepSeconds/3600);
    NSInteger quietSleepMinute = (int)(quietSleepSeconds - quietSleepHour*3600)/60;
    NSString* zero =@"";
    if(quietSleepMinute < 10){
        zero = @"0";
    }
    NSString *quietSleepTime = [NSString stringWithFormat:@"%ld %@ %@%ld %@", (long)quietSleepHour,kLoadStringWithKey(@"HealthRecord_VC_sleepHour"),zero,(long)quietSleepMinute,kLoadStringWithKey(@"HealthRecord_VC_sleepMin")];
    
    return quietSleepTime;
}

-(NSString*)deepSleepTotalTime{
    NSArray* array = [_duration componentsSeparatedByString:@":"];
    NSInteger hour = [array.firstObject intValue];
    NSInteger minute = [array.lastObject intValue];
    
    NSInteger totalSeconds = hour*60*60 + minute*60;
    NSInteger deepSleepPercent = 100 - _quietSleepPercent;
    
    NSTimeInterval deepSleepSeconds = totalSeconds * (deepSleepPercent/100.0);
    
    NSInteger deepSleepHour = (int)(deepSleepSeconds/3600);
    NSInteger deepSleepMinute = (int)(deepSleepSeconds - deepSleepHour*3600)/60;
    NSString* zero =@"";
    if(deepSleepMinute < 10){
        zero = @"0";
    }
    NSString *deepSleepTime = [NSString stringWithFormat:@"%ld %@ %@%ld %@", (long)deepSleepHour,kLoadStringWithKey(@"HealthRecord_VC_sleepHour"),zero,(long)deepSleepMinute,kLoadStringWithKey(@"HealthRecord_VC_sleepMin")];
    
    return deepSleepTime;
}

-(NSString*)activeTime{
    
    NSArray* array = [_activeTime componentsSeparatedByString:@":"];
    NSInteger activeTimeMin = [array.lastObject intValue];
    NSString* zero =@"";
    if(activeTimeMin<10){
        zero =@"0";
    }
    return [NSString stringWithFormat:@"%d %@ %@%d %@",[array.firstObject intValue],
            kLoadStringWithKey(@"HealthRecord_VC_sleepHour"),zero,[array.lastObject intValue],kLoadStringWithKey(@"HealthRecord_VC_sleepMin")
            ];
}

-(NSString*)lastCollectTime{
    return @"";
}

-(NSArray*)sleepQulityTimes{
    NSMutableArray* timeArray = [NSMutableArray array];
    _sleepQulityStates = [NSMutableArray array];
    
    NSInteger currentValue = 0;
    
    for(int index =0 ; index < _sleepQulityPercentList.count; index++){
        NSDictionary* dictionary= _sleepQulityPercentList[index];
        NSString* time = dictionary[@"time"];
        NSInteger type = [dictionary[@"type"] intValue];
        
        if(index == 0 || index == _sleepQulityPercentList.count-1 || currentValue != type){
            [timeArray addObject:time];
            if(currentValue == 0){
                [_sleepQulityStates addObject:@"1"];
            }else{
                [_sleepQulityStates addObject:@"1.5"];
            }

        }
        
        currentValue = type;
    }
    return timeArray;
}

@end
