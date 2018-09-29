//
//  KMAuthenticationCell.m
//  InstantCare
//
//  Created by KM on 2016/11/30.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAuthenticationCell.h"

@implementation KMAuthenticationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    
    static NSString *ID = @"AuthenticationCell";
    KMAuthenticationCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([KMAuthenticationCell class]) owner:nil options:nil] lastObject];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.textLabel.text = kLoadStringWithKey(title);
}

@end
