//
//  KMLocationCardCell.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/19.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMLocationCardCell.h"

#define kButtonFontSize         15

@interface KMLocationCardCell()
/**
 *  签入按钮
 */
@property (nonatomic, strong) UIButton *inButton;
/**
 *  签出按钮
 */
@property (nonatomic, strong) UIButton *outButton;

@end

@implementation KMLocationCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configCell];
    }

    return self;
}

- (void)configCell {
    self.inButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inButton.tag = 0;
    self.inButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.inButton setTitleColor:kGrayContextColor forState:UIControlStateNormal];
    [self.inButton setTitleColor:kMainColor forState:UIControlStateSelected];
    [self.inButton setImage:[UIImage imageNamed:@"position_circle_green_normal"] forState:UIControlStateNormal];
    [self.inButton setImage:[UIImage imageNamed:@"position_circle_green_sel"] forState:UIControlStateSelected];
    [self.inButton addTarget:self action:@selector(cellBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.inButton];
    [self.inButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_centerX);
    }];
    
    self.outButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.outButton.tag = 1;
    self.outButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.outButton setTitleColor:kGrayContextColor forState:UIControlStateNormal];
    [self.outButton setTitleColor:kMainColor forState:UIControlStateSelected];
    [self.outButton setImage:[UIImage imageNamed:@"position_circle_orange_normal"] forState:UIControlStateNormal];
    [self.outButton setImage:[UIImage imageNamed:@"position_circle_orange_sel"] forState:UIControlStateSelected];
    [self.outButton addTarget:self action:@selector(cellBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.outButton];
    [self.outButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_centerX);
    }];
}

- (void)cellBtnDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cellBtnDidClickWithCell:btnIndex:)]) {
        [self.delegate cellBtnDidClickWithCell:self btnIndex:sender.tag];
    }
}

- (void)setCheckinDate:(NSString *)checkinDate {
    [self.inButton setTitle:checkinDate forState:UIControlStateNormal];
    [self.inButton setTitle:checkinDate forState:UIControlStateSelected];
}

- (void)setCheckOutDate:(NSString *)checkOutDate {
    [self.outButton setTitle:checkOutDate forState:UIControlStateNormal];
    [self.outButton setTitle:checkOutDate forState:UIControlStateSelected];
}

- (void)setSelectBtnIndex:(NSInteger)selectBtnIndex {
    if (selectBtnIndex == 0) {
        self.inButton.selected = YES;
        self.outButton.selected = NO;
    } else if (selectBtnIndex == 1) {
        self.inButton.selected = NO;
        self.outButton.selected = YES;
    } else {
        self.inButton.selected = NO;
        self.outButton.selected = NO;
    }
}

@end




