//
//  JKAlert.m
//  AlertAssemble
//
//  Created by 四威 on 2016/8/1.
//  Copyright © 2016年 JeanKyle. All rights reserved.
//

#import "JKAlert.h"
#import "JKAlertManager.h"
#import "NSObject+JKAlert.h"
#import "NSString+JKAlert.h"

@implementation JKAlert

#pragma mark - 文字提示相关
+ (void)alertText:(NSString *)text {
    JK_M.duration = DURATION_DEFAULT;
    [self alertContentsWithText:text];
}
+ (void)alertText:(NSString *)text duration:(NSTimeInterval)duration {
    JK_M.duration = duration;
    [self alertContentsWithText:text];
}
+ (void)alertContentsWithText:(NSString *)text {
    JK_M.isAlerted = YES;

    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat containMaxWidth = SCREEN_WIDTH - 100;
    CGFloat textMaxWidth = containMaxWidth - 30;
    JK_M.textLabel = [[JKAdapterLabel alloc] initWithText:text font:font maxWitdth:textMaxWidth];
    JK_M.textLabel.center = SCREEN_CENTER;
    
    [JK_M containSize:CGSizeMake(JK_M.textLabel.jk_width + 30, JK_M.textLabel.jk_height + 20) block:^(CGFloat num) {
        [JK_M.mainWindow addSubview:JK_M.textLabel];
    }];

    [JK_M elastAllAlertViews];
    NSUInteger markCode = JK_M.timestamp;
    [JK_M markCodeAllAlertViews:markCode];
    [JK_M dismissDuration:JK_M.duration markCodeInt:markCode];
}
#pragma mark - 等待视图相关
+ (void)alertWaiting:(BOOL)isAlert {
    [JK_M waitingJudge:isAlert block:^{
        JK_M.isAlerted = YES;
        [JK_M containSide:SCREEN_WIDTH * 0.2 block:^(CGFloat num) {
            CGFloat iWH = num * 0.7;
            JK_M.waitView = [[JKWaitingView alloc] initWithFrame:CGRectMake(0, 0, iWH, iWH)];
            JK_M.waitView.center = SCREEN_CENTER;
            [JK_M.mainWindow addSubview:JK_M.waitView];
        }];
        [JK_M coverEnable:YES];
        NSUInteger markCode = JK_M.timestamp;
        [JK_M markCodeAllAlertViews:markCode];
        [JK_M elastAllAlertViews];
    }];
}
+ (void)alertWaitingText:(NSString *)text {
    [JK_M waitingJudge:YES block:^{
        JK_M.isAlerted = YES;
        CGFloat cWH = SCREEN_WIDTH * ONE_SEVENTH;
        CGFloat containMaxWidth = SCREEN_WIDTH - 100;
        CGFloat textMaxWidth = containMaxWidth - 30;
        JK_M.textLabel = [[JKAdapterLabel alloc] initWithText:text font:[UIFont systemFontOfSize:15] maxWitdth:textMaxWidth];
        JK_M.waitView = [[JKWaitingView alloc] initWithFrame:CGRectMake(0, 0, cWH, cWH)];

        JK_M.waitView.center = CGPointMake(half(SCREEN_WIDTH), half(SCREEN_HEIGHT) - half(JK_M.textLabel.jk_height));
        JK_M.textLabel.center  = JK_M.waitView.center;
        JK_M.textLabel.jk_y = JK_M.waitView.jk_y + JK_M.waitView.jk_height;

        if (JK_M.textLabel.jk_width < JK_M.waitView.jk_width) {
            JK_M.textLabel.jk_width = JK_M.waitView.jk_width;
        }

        [JK_M containSize:CGSizeMake(JK_M.textLabel.jk_width + 20, JK_M.textLabel.jk_height + JK_M.waitView.jk_height + 20) block:^(CGFloat num) {
            [JK_M.mainWindow addSubview:JK_M.waitView];
            [JK_M.mainWindow addSubview:JK_M.textLabel];
        }];
        [JK_M coverEnable:YES];
        NSUInteger markCode = JK_M.timestamp;
        [JK_M markCodeAllAlertViews:markCode];
        [JK_M elastAllAlertViews];
    }];
}
#pragma mark - 标识视图相关
+ (void)alertTick {
    JK_M.duration = DURATION_DEFAULT;
    [self alertInformWithStyle:JKInformStyleTick];
}
+ (void)alertTickDuration:(NSTimeInterval)duration {
    JK_M.duration = duration;
    [self alertInformWithStyle:JKInformStyleTick];
}
+ (void)alertTickText:(NSString *)text {
    JK_M.duration = DURATION_DEFAULT;
    [self alertInformWithStyle:JKInformStyleTick text:text];
}
+ (void)alertTickText:(NSString *)text duration:(NSTimeInterval)duration {
    JK_M.duration = duration;
    [self alertInformWithStyle:JKInformStyleTick text:text];
}
+ (void)alertCross {
    JK_M.duration = DURATION_DEFAULT;
    [self alertInformWithStyle:JKInformStyleCross];
}
+ (void)alertCrossDuration:(NSTimeInterval)duration {
    JK_M.duration = duration;
    [self alertInformWithStyle:JKInformStyleCross];
}
+ (void)alertCrossText:(NSString *)text {
    JK_M.duration = DURATION_DEFAULT;
    [self alertInformWithStyle:JKInformStyleCross text:text];
}
+ (void)alertCrossText:(NSString *)text duration:(NSTimeInterval)duration {
    JK_M.duration = duration;
    [self alertInformWithStyle:JKInformStyleCross text:text];
}

+ (void)alertInformWithStyle:(JKInformStyle)style{
    JK_M.isAlerted = YES;

    [JK_M containSide:SCREEN_WIDTH * 0.3 block:^(CGFloat num) {
        CGFloat iWH = num * 0.4;
        JK_M.informView = [[JKInformView alloc] initWithFrame:CGRectMake(0, 0, iWH, iWH) style:style];
        JK_M.informView.center = SCREEN_CENTER;
        [JK_M.mainWindow addSubview:JK_M.informView];
    }];

    NSUInteger markCode = JK_M.timestamp;
    [JK_M markCodeAllAlertViews:markCode];
    [JK_M dismissDuration:JK_M.duration markCodeInt:markCode];
    [JK_M elastAllAlertViews];
}
+ (void)alertInformWithStyle:(JKInformStyle)style text:(NSString *)text {
    JK_M.isAlerted = YES;
    CGFloat containMaxWidth = SCREEN_WIDTH - 100;
    CGFloat cWH = SCREEN_WIDTH * 0.1;
    CGFloat textMaxWidth = containMaxWidth - 30;
    JK_M.textLabel = [[JKAdapterLabel alloc] initWithText:text font:[UIFont systemFontOfSize:15] maxWitdth:textMaxWidth];
    JK_M.informView = [[JKInformView alloc] initWithFrame:CGRectMake(0, 0, cWH, cWH) style:style];

    JK_M.informView.center = CGPointMake(half(SCREEN_WIDTH), half(SCREEN_HEIGHT) - half(JK_M.textLabel.jk_height));
    JK_M.textLabel.center  = JK_M.informView.center;
    JK_M.textLabel.jk_y = JK_M.informView.jk_y + JK_M.informView.jk_height + 5;

    if (JK_M.textLabel.jk_width < JK_M.informView.jk_width) {
        JK_M.textLabel.jk_width = JK_M.informView.jk_width;
    }

    [JK_M containSize:CGSizeMake(JK_M.textLabel.jk_width + 20, JK_M.textLabel.jk_height + JK_M.informView.jk_height + 25) block:^(CGFloat num) {
        [JK_M.mainWindow addSubview:JK_M.informView];
        [JK_M.mainWindow addSubview:JK_M.textLabel];
    }];

    NSUInteger markCode = JK_M.timestamp;
    [JK_M markCodeAllAlertViews:markCode];
    [JK_M dismissDuration:JK_M.duration markCodeInt:markCode];
    [JK_M elastAllAlertViews];
}

@end
