//
//  KMCustomButton.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCustomButton.h"

@implementation KMCustomButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    
    center.y -= (self.imageView.frame.size.height / 2.0 + 1);
    self.imageView.center = center;
    
    // label的frame也设置一下
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.titleLabel.frame.size.height);
    self.titleLabel.frame = frame;
    center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    center.y += (self.titleLabel.frame.size.height / 2.0 + 1);
    self.titleLabel.center = center;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}


@end
