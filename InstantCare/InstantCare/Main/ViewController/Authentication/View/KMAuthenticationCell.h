//
//  KMAuthenticationCell.h
//  InstantCare
//
//  Created by KM on 2016/11/30.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMAuthenticationCell : UITableViewCell

/**
 *title
 */
@property (nonatomic,copy)NSString *title;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
