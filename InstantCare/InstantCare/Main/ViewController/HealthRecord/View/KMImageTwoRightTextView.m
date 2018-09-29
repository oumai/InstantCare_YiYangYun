//
//  KMImageTwoLeftTextView.m
//  InstantCare
//
//  Created by Frank He on 9/8/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMImageTwoRightTextView.h"

@implementation KMImageTwoRightTextView

-(instancetype)initWithImage:(UIImage*)image
                rightTopText:(NSString*)topText
                     topFont:(NSInteger)topFont
             rightBottomText:(NSString *)bottomText
                  bottomFont:(NSInteger)bottomFont {
    
    if(self == [super init]){
        [self loadSubViewWithImage:image rightTopText:topText topFont:topFont rightBottomText:bottomText bottomFont:bottomFont];
    }
    
    return  self;
}

-(void)loadSubViewWithImage:(UIImage*)image
               rightTopText:(NSString*)topText
                    topFont:(NSInteger)topFont
            rightBottomText:(NSString*)bottomText
                 bottomFont:(NSInteger)bottomFont{
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    UILabel* rightTopLabel = [UILabel new];
    rightTopLabel.font = [UIFont systemFontOfSize:topFont];
    rightTopLabel.text = topText;
    [self addSubview:rightTopLabel];
    
    UILabel* rightBottomLabel = [UILabel new];
    rightBottomLabel.font = [UIFont systemFontOfSize:bottomFont];
    rightBottomLabel.text = bottomText;
    [self addSubview:rightBottomLabel];
    rightBottomLabel.adjustsFontSizeToFitWidth = YES;
    
    WS(weakSelf);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(weakSelf);
        make.height.equalTo(@16);
        make.width.equalTo(@16);
    }];
    
    [rightTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(weakSelf);
        make.left.equalTo(imageView.mas_right).offset(1);
        make.height.equalTo(@15);
    }];
    
    [rightBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf);
        make.top.equalTo(rightTopLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf);
        make.height.equalTo(@15);
    }];
}

@end
