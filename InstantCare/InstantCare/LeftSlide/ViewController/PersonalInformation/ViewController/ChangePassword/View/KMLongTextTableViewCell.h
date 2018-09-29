//
//  KMLongTextTableViewCell.h
//  InstantCare
//
//  Created by Frank He on 9/19/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const cKMLongTextTableViewCell;

@interface KMLongTextTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *longTextView;

+ (CGFloat)cellHeightForText:(NSString*)text inTableView:(UITableView*)tableView;

@end
