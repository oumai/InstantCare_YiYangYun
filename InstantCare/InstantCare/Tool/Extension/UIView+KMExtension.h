//
//  UIView+KMExtension.h
//  InstantCare
//
//  Created by KM on 2016/12/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KMExtension)

@property (nonatomic, assign) CGSize xlh_size;
@property (nonatomic, assign) CGFloat xlh_width;
@property (nonatomic, assign) CGFloat xlh_height;
@property (nonatomic, assign) CGFloat xlh_x;
@property (nonatomic, assign) CGFloat xlh_y;
@property (nonatomic, assign) CGFloat xlh_centerX;
@property (nonatomic, assign) CGFloat xlh_centerY;

@property (nonatomic, assign) CGFloat xlh_right;
@property (nonatomic, assign) CGFloat xlh_bottom;

+ (instancetype)viewFromXib;

@end
