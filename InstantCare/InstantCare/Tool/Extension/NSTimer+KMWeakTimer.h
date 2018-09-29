//
//  NSTimer+KMWeakTimer.h
//  InstantCare
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 kangmei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (KMWeakTimer)
+(NSTimer *)KM_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        block:(void(^)())block
                                      repeats:(BOOL)repeats;
@end
