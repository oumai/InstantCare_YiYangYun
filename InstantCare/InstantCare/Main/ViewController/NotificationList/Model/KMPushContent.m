//
//  KMPushContent.m
//  InstantCare
//
//  Created by KM on 2016/11/25.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMPushContent.h"
#import "KMExtrasModel.h"
#import "KMAlter.h"

@implementation KMPushContent

-(void)setP_create_time:(NSString *)p_create_time
{
   NSString *timeStr = [self convertStrToTime:p_create_time];
    
    _p_create_time = timeStr;
}

- (NSString *)convertStrToTime:(NSString *)timeStr

{
    
    long long time=[timeStr longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
//    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString*timeString=[formatter stringFromDate:d];
    
    return timeString;
    
}

@end
