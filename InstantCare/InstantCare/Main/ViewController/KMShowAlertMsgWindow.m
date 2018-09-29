//
//  KMShowAlertMsgWindow.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/22.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMShowAlertMsgWindow.h"

#define kMsgViewHeight      (SCREEN_HEIGHT*0.25)

@interface KMShowAlertMsgWindow()

@property (nonatomic, strong) UILabel *msgLabel;

@end

@implementation KMShowAlertMsgWindow

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    WS(ws);

    self = [super initWithFrame:frame];
    if (self) {
        UIView *blackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:blackView];

        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        visualEffectView.alpha = 1.0;
        [self addSubview:visualEffectView];
        [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.centerY.equalTo(ws);
            make.height.equalTo(@kMsgViewHeight);
        }];

        UITapGestureRecognizer* singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
        singleFingerOne.numberOfTouchesRequired = 1;
        singleFingerOne.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleFingerOne];

        self.msgLabel = [[UILabel alloc] init];
        self.msgLabel.numberOfLines = 0;
        self.msgLabel.textAlignment = NSTextAlignmentCenter;
        self.msgLabel.font = [UIFont systemFontOfSize:25];
        [visualEffectView addSubview:self.msgLabel];
        [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(visualEffectView);
            make.width.equalTo(visualEffectView).multipliedBy(0.7);
        }];
    }

    return self;
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    [self hide];
}

- (void)showMsg:(NSString *)msg
{
    self.msgLabel.text = msg;
    [self makeKeyAndVisible];
    self.hidden = NO;
}

- (void)hide
{
    [self resignFirstResponder];
    self.hidden = YES;
}

@end
