//
//  KMSimTextField.m
//  InstantCare
//
//  Created by KM on 2016/11/29.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSimTextField.h"

@implementation KMSimTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置光标的颜色
        self.tintColor = [UIColor grayColor];
        
        [self setInputAccessoryView:[UIView new]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置光标的颜色
    self.tintColor = [UIColor grayColor];
    
    [self setInputAccessoryView:[UIView new]];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.leftView.frame;
    frame.origin.x += 10;
    self.leftView.frame = frame;
}

@end
