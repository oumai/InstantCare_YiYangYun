//
//  KMCallCell.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCallCell : UITableViewCell

@property (nonatomic, readonly, strong) UIImageView *headImageView;
@property (nonatomic, readonly, strong) UIImageView *watchImageView;
@property (nonatomic, readonly, strong) UILabel *nameLabel;
@property (nonatomic, readonly, strong) UILabel *phoneLabel;

@end
