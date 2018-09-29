//
//  UIView+KMExtension.m
//  InstantCare
//
//  Created by KM on 2016/12/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "UIView+KMExtension.h"

@implementation UIView (KMExtension)

- (CGSize)xlh_size
{
    return self.frame.size;
}

- (void)setXlh_size:(CGSize)xlh_size
{
    CGRect frame = self.frame;
    frame.size = xlh_size;
    self.frame = frame;
}

- (CGFloat)xlh_width
{
    return self.frame.size.width;
}

- (CGFloat)xlh_height
{
    return self.frame.size.height;
}

- (void)setXlh_width:(CGFloat)xlh_width
{
    CGRect frame = self.frame;
    frame.size.width = xlh_width;
    self.frame = frame;
}

- (void)setXlh_height:(CGFloat)xlh_height
{
    CGRect frame = self.frame;
    frame.size.height = xlh_height;
    self.frame = frame;
}

- (CGFloat)xlh_x
{
    return self.frame.origin.x;
}

- (void)setXlh_x:(CGFloat)xlh_x
{
    CGRect frame = self.frame;
    frame.origin.x = xlh_x;
    self.frame = frame;
}

- (CGFloat)xlh_y
{
    return self.frame.origin.y;
}

- (void)setXlh_y:(CGFloat)xlh_y
{
    CGRect frame = self.frame;
    frame.origin.y = xlh_y;
    self.frame = frame;
}

- (CGFloat)xlh_centerX
{
    return self.center.x;
}

- (void)setXlh_centerX:(CGFloat)xlh_centerX
{
    CGPoint center = self.center;
    center.x = xlh_centerX;
    self.center = center;
}

- (CGFloat)xlh_centerY
{
    return self.center.y;
}

- (void)setXlh_centerY:(CGFloat)xlh_centerY
{
    CGPoint center = self.center;
    center.y = xlh_centerY;
    self.center = center;
}

- (CGFloat)xlh_right
{
    //    return self.xmg_x + self.xmg_width;
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)xlh_bottom
{
    //    return self.xmg_y + self.xmg_height;
    return CGRectGetMaxY(self.frame);
}

- (void)setXlh_right:(CGFloat)xlh_right
{
    self.xlh_x = xlh_right - self.xlh_width;
}

- (void)setXlh_bottom:(CGFloat)xlh_bottom
{
    self.xlh_y = xlh_bottom - self.xlh_height;
}

+(instancetype)viewFromXib
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
}



@end
