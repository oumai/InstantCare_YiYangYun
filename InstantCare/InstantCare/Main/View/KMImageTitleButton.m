//
//  KMImageTitleButton.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/30.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMImageTitleButton.h"

@implementation KMImageTitleButton

#define kIconViewWidth      40
#define kFontSize           14

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    self = [super init];
    if (self) {
        UIView *view = [[UIView alloc] init];

        self.iconView = [[UIImageView alloc] init];
        self.iconView.image = image;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(view);
            make.height.equalTo(@(42));
        }];

        self.label = [[UILabel alloc] init];
        self.label.textColor = kGrayContextColor;
        self.label.text = title;
        self.label.numberOfLines = 0;
        self.label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.top.equalTo(self.iconView.mas_bottom).offset(5);
        }];
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.label.mas_bottom);
            make.centerY.equalTo(self);
        }];
        
        self.iconView.userInteractionEnabled = NO;
        self.label.userInteractionEnabled = NO;
        view.userInteractionEnabled = NO;
    }

    return self;
}


- (instancetype)initWithLeftImage:(UIImage *)image title:(NSString *)title
{
    self = [super init];
    if (self) {
        UIView *view = [[UIView alloc] init];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.image = image;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view);
            make.centerY.equalTo(view);
            make.width.height.equalTo(@(kIconViewWidth));
        }];
        
        self.label = [[UILabel alloc] init];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = title;
        self.label.numberOfLines = 0;
        
        [view addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).with.offset(5);
            make.top.bottom.equalTo(view);
        }];
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.label);
            make.centerX.top.bottom.equalTo(self);
            make.width.lessThanOrEqualTo(self);
        }];
        
        self.iconView.userInteractionEnabled = NO;
        self.label.userInteractionEnabled = NO;
        view.userInteractionEnabled = NO;
    }
    
    return self;
}


@end
