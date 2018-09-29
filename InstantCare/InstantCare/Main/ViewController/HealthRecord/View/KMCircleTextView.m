//
//  KMCircleTextView.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/3.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCircleTextView.h"

#define kCircleWidth        10

@interface KMCircleTextView()

@property (nonatomic, strong) UIView *circleView;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation KMCircleTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
    }
    
    return self;
}

- (void)configView {
    _circleView = [[UIView alloc] init];
    _circleView.backgroundColor = [UIColor grayColor];
    _circleView.layer.cornerRadius = kCircleWidth / 2.0;
    _circleView.clipsToBounds = YES;
    [self addSubview:_circleView];
    [_circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(kCircleWidth));
        make.left.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_textLabel];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_circleView.mas_right).offset(5);
        make.right.equalTo(self);
        make.centerY.equalTo(self);
    }];
}

- (void)setText:(NSString *)text {
    CGSize sizeName = [text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:_textLabel.font}] : CGSizeZero;
    _textLabel.text = text;
    self.frame = CGRectMake(0, 0, kCircleWidth + 5 + sizeName.width + 2, sizeName.height);
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleView.backgroundColor = circleColor;
}

@end
