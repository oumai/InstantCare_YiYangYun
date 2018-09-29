//
//  KMNewTitleImageBtn.h
//  InstantCare
//
//  Created by Jasonh on 16/12/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMNewTitleImageBtn : UIButton
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
@end
