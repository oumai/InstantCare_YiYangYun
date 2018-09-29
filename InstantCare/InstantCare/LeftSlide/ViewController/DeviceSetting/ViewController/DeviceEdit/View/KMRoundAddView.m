//
//  KMRoundAddView.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMRoundAddView.h"

#define kAddButtonSize      30

@interface KMRoundAddView()

@property (nonatomic, strong) UIImageView *bottomImageView;

@end

@implementation KMRoundAddView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
    }
    
    return self;
}

- (void)configView {
    self.bottomImageView = [UIImageView new];
    [self addSubview:self.bottomImageView];
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIImageView *addImageView = [[UIImageView alloc] init];
    addImageView.layer.cornerRadius = kAddButtonSize/2.0;
    addImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    addImageView.clipsToBounds = YES;
    addImageView.image = [UIImage imageNamed:@"edit_button_edit_photo"];
    [self addSubview:addImageView];
    [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.width.height.equalTo(@kAddButtonSize);
    }];
}

@end
