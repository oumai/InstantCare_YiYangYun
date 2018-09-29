//
//  NSTimer+KMWeakTimer.m
//  InstantCare
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 kangmei. All rights reserved.
//

#import "NSTimer+KMWeakTimer.h"

@implementation NSTimer (KMWeakTimer)
+(NSTimer *)KM_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        block:(void(^)())block
                                      repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(KM_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}
+(void)KM_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if(block) {
        block();
    }
}
@end
