//
//  KMCustomTextField.m
//  InstantCare
//
//  Created by km on 16/6/6.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCustomTextField.h"

@interface KMCustomTextField ()<UITextFieldDelegate>

@end


@implementation KMCustomTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configSubViews];
        
    }
    return self;
}

#pragma mark --- 初始化子类视图
-(void)configSubViews{
    // 标题；
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    // 内容；
    self.contentTextField = [[UITextField alloc] init];
    self.contentTextField.textAlignment = NSTextAlignmentCenter;
    self.contentTextField.borderStyle = UITextBorderStyleNone;
    self.contentTextField.delegate = self;
    [self addSubview:self.contentTextField];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.contentTextField becomeFirstResponder];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(self.frame.size.height/5*2);
    }];
    [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(0);
    }];
    UIView * grayLine = [[UIView alloc] init];
    grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    [self addSubview:grayLine];
    [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    self.grayLine = grayLine;
}

#pragma  mark -UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.grayLine.backgroundColor = [UIColor orangeColor];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
}


@end
