//
//  KMLongTextTableViewCell.m
//  InstantCare
//
//  Created by Frank He on 9/19/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMLongTextTableViewCell.h"

#define kEdgeOffset     30
#define kPadding 25
NSString * const cKMLongTextTableViewCell = @"KMLongTextTableViewCell";

@implementation KMLongTextTableViewCell

-(CGFloat)cellHeight{
    [self layoutIfNeeded];
    CGSize textViewSize = [self.longTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.longTextView.frame), FLT_MAX)];
    CGFloat height = textViewSize.height;
    return MAX(height,70);
}

+ (CGFloat)cellHeightForText:(NSString*)text inTableView:(UITableView*)tableView{
    return [KMLongTextTableViewCell cellHeightForText:text
                                   inTableView:tableView
                             withAccessoryType:UITableViewCellAccessoryNone];
}

+ (CGFloat)cellHeightForText:(NSString*)text inTableView:(UITableView*)tableView withAccessoryType:(UITableViewCellAccessoryType)type{
    static KMLongTextTableViewCell* staticCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[KMLongTextTableViewCell class]];
        staticCell = [bundle loadNibNamed:cKMLongTextTableViewCell owner:nil options:nil].firstObject;
    });
    
    staticCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(staticCell.bounds));
    staticCell.accessoryType = type;
    staticCell.longTextView.text = text;
    return [staticCell cellHeight];
}

@end
