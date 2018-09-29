//
//  UIView+Frame.h
//  QuartzFun
//
//  Created by km on 16/7/4.
//  Copyright © 2016年 mission. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height



@interface UIView (Extension)

/** 宽 */
@property(nonatomic,assign)CGFloat width;

/** 高 */
@property(nonatomic,assign)CGFloat height;

/** 位置 */
@property(nonatomic,assign)CGPoint origin;

/** 尺寸 */
@property(nonatomic,assign)CGSize  size;


/** 位置x坐标 */
@property(nonatomic,assign)CGFloat originX;

/** 位置Y坐标 */
@property(nonatomic,assign)CGFloat originY;

/** 中心店x坐标 */
@property(nonatomic,assign)CGFloat centerX;

/** 中心店y坐标 */
@property(nonatomic,assign)CGFloat centerY;

@end
