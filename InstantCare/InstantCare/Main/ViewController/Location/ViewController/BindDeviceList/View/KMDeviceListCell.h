//
//  KMDeviceListCell.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMDeviceListCell : UITableViewCell
/**
 *  用户头像
 */
@property (nonatomic, strong, readonly) UIImageView *userHeaderImageView;
/**
 *  用户姓名
 */
@property (nonatomic, strong, readonly) UILabel *userNameLabel;
/**
 *  用户电话号码
 */
@property (nonatomic, strong, readonly) UILabel *userPhoneLabel;

@end
