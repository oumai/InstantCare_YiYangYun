//
//  KMCommonInputCell.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCommonInputCell.h"

#define kEdgeOffset     30

@interface KMCommonInputCell()

@property (nonatomic, strong) UITextField *textField;
/**
 *  右边图标，在accessType左边
 */
@property (nonatomic, strong) UIImageView *rightImageView;
/**
 *  同意协议
 */
@property (nonatomic, strong) UIButton *imageTitleBtn;

@end

@implementation KMCommonInputCell

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
    self.textField = [[UITextField alloc] init];
    [self.contentView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(kEdgeOffset/2);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kEdgeOffset);
    }];
    
    self.rightImageView = [[UIImageView alloc] init];
    self.rightImageView.layer.cornerRadius = 5;
    self.rightImageView.clipsToBounds = YES;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.rightImageView];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.textField);
        make.width.height.equalTo(@45);
    }];
}

- (UIButton *)imageTitleBtn {
    if (_imageTitleBtn == nil) {
        _imageTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageTitleBtn.userInteractionEnabled = NO;
        _imageTitleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _imageTitleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_imageTitleBtn setTitleColor:kGrayTipColor forState:UIControlStateNormal];
        [_imageTitleBtn setTitleColor:kGrayTipColor forState:UIControlStateSelected];
        [_imageTitleBtn setTitle:kLoadStringWithKey(@"DeviceSetting_VC_agree_protocol") forState:UIControlStateNormal];
        [_imageTitleBtn setTitle:kLoadStringWithKey(@"DeviceSetting_VC_agree_protocol") forState:UIControlStateSelected];
        [_imageTitleBtn setImage:[UIImage imageNamed:@"register_unagree"] forState:UIControlStateNormal];
        [_imageTitleBtn setImage:[UIImage imageNamed:@"register_agree"] forState:UIControlStateSelected];
        [self.contentView addSubview:_imageTitleBtn];
        [_imageTitleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(45);
            make.top.right.bottom.equalTo(self.contentView);
        }];
    }
    
    return _imageTitleBtn;
}

@end
