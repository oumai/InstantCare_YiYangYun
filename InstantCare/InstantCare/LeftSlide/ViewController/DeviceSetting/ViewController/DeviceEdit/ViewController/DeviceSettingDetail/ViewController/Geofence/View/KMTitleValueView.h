//
//  KMTitleValueView.h
//  InstantCare
//
//  Created by bruce zhu on 16/8/11.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 电子围栏：左边显示名称，右边显示数值
@interface KMTitleValueView : UIView

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value;

/// 左边标题
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 右边数值
@property (nonatomic, strong, readonly) UILabel *valueLabel;

/// 底部灰色的线条
@property (nonatomic, strong, readonly) UIView *bottomLineView;

@end
