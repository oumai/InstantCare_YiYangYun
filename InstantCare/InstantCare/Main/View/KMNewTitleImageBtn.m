//
//  KMNewTitleImageBtn.m
//  InstantCare
//
//  Created by Jasonh on 16/12/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMNewTitleImageBtn.h"
#import "UIImage+Extension.h"
@implementation KMNewTitleImageBtn

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title{
    self = [super init];
    if (self) {
        UIImage *imag_hig = [UIImage imageWithColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00]];
        UIImage *imag_nor = [UIImage imageWithColor:[UIColor whiteColor]];
        [self setBackgroundImage:imag_hig forState:UIControlStateHighlighted];
        [self setBackgroundImage:imag_nor forState:UIControlStateNormal];
        
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.image = image;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view).offset(-18);
            make.height.width.equalTo(@(50));
            make.centerX.equalTo(view);
        }];
        
        self.label = [[UILabel alloc] init];
        self.label.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.49 alpha:1.00];
//        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.text = title;
        self.label.numberOfLines = 0;
        
        [view addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconView.mas_bottom).offset(8);
            make.centerX.equalTo(self.iconView);
            make.width.lessThanOrEqualTo(view).offset(16);
        }];

        self.iconView.userInteractionEnabled = NO;
        self.label.userInteractionEnabled = NO;
        view.userInteractionEnabled = NO;
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
