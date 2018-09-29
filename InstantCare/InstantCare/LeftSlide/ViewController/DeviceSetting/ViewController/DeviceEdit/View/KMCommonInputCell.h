//
//  KMCommonInputCell.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCommonInputCell : UITableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;
/**
 *  右边图标，在accessType左边
 */
@property (nonatomic, strong, readonly) UIImageView *rightImageView;
/**
 *  同意协议
 */
@property (nonatomic, strong, readonly) UIButton *imageTitleBtn;

@end
