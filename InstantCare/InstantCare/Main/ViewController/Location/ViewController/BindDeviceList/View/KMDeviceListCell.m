//
//  KMDeviceListCell.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMDeviceListCell.h"

#define kHeaderImageViewSize            50
#define kEdgeOffset                     20

@interface KMDeviceListCell()
/**
 *  用户头像
 */
@property (nonatomic, strong) UIImageView *userHeaderImageView;
/**
 *  用户姓名
 */
@property (nonatomic, strong) UILabel *userNameLabel;
/**
 *  用户电话号码
 */
@property (nonatomic, strong) UILabel *userPhoneLabel;

@end

@implementation KMDeviceListCell

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
    self.userHeaderImageView = [UIImageView new];
    self.userHeaderImageView.layer.cornerRadius = kHeaderImageViewSize/2;
    self.userHeaderImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.userHeaderImageView];
    [self.userHeaderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kEdgeOffset);
        make.width.height.equalTo(@kHeaderImageViewSize);
        make.centerY.equalTo(self.contentView);
    }];
    
    self.userNameLabel = [UILabel new];
    self.userNameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:self.userNameLabel];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userHeaderImageView.mas_right).offset(kEdgeOffset);
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-2);
    }];
    
    self.userPhoneLabel = [UILabel new];
    self.userPhoneLabel.textColor = kGrayTipColor;
    self.userPhoneLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.userPhoneLabel];
    [self.userPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userNameLabel);
        make.top.equalTo(self.contentView.mas_centerY).offset(2);
    }];
}

@end
