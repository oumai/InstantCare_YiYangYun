//
//  KMTitleValueView.m
//  InstantCare
//
//  Created by bruce zhu on 16/8/11.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMTitleValueView.h"

#define kFontSize       15

@interface KMTitleValueView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation KMTitleValueView

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value {
    if (self = [super init]) {
        [self configViewWithTitle:title value:value];
    }
    
    return self;
}

- (void)configViewWithTitle:(NSString *)title value:(NSString *)value {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
        
    }];
    
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.text = value;
    self.valueLabel.textColor = kGrayTipColor;
    self.valueLabel.font = [UIFont systemFontOfSize:kFontSize];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-20);
    }];
    
    self.bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = kGrayBackColor;
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@1);
    }];
}



@end
