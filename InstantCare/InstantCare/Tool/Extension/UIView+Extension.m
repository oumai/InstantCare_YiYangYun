//
//  UIView+Frame.m
//  QuartzFun
//
//  Created by km on 16/7/4.
//  Copyright © 2016年 mission. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

/** 宽Setter Getter 方法 */
-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    return;
    ;
}

-(CGFloat)width
{
    return self.frame.size.width;
}

/** 高Setter Getter 方法 */
-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.width = height;
    self.frame = frame;
    return;

}
-(CGFloat)height
{
    return self.frame.size.height;
}


/** 位置x坐标  Setter Getter 方法 */
-(void)setOriginX:(CGFloat)originX
{
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
    return;

}
-(CGFloat)originX
{
    return self.frame.origin.x;
}


/** 位置origin Setter Getter 方法 */
-(void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
    return;

}
-(CGPoint)origin
{
    return self.frame.origin;
}


/** 尺寸 Setter Getter 方法*/
-(void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    return;
    
}
-(CGSize)size
{
    return self.frame.size;
}


/** 位置Y坐标 Setter Getter 方法*/
-(void)setOriginY:(CGFloat)originY
{
    CGRect frame = self.frame;
    frame.origin.x = originY;
    self.frame = frame;
    return;

}
-(CGFloat)originY
{
    return  self.frame.origin.y;
}



/** 中心店x坐标 Setter Getter 方法*/
-(void)setCenterX:(CGFloat)centerX
{
    CGRect frame = self.frame;
    frame.origin.x = centerX;
    self.frame = frame;
    return;

}

-(CGFloat)centerX
{
    return self.center.x;
}



/** 中心店y坐标 Setter Getter 方法*/
-(void)setCenterY:(CGFloat)centerY
{
    CGRect frame = self.frame;
    frame.origin.x = centerY;
    self.frame = frame;
    return;

}
-(CGFloat)centerY
{
    return self.center.y;
}







@end
