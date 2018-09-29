//
//  KMDeviceSettingEditCell.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/3.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingEditCell.h"

@interface KMDeviceSettingEditCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation KMDeviceSettingEditCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configCell];
    }
    
    return self;
}

- (void)configCell
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor orangeColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(20);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).with.offset(10);
        make.height.equalTo(@30);
    }];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.right.equalTo(self.contentView);
    }];
}


@end
