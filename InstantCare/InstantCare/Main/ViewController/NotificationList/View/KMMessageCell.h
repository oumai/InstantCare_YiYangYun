//
//  KMMessageCell.h
//  InstantCare
//
//  Created by zxy on 2016/11/30.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMPushListModel.h"

@protocol KMMessageCellDelegate <NSObject>

- (void)selectCellWithIndex:(NSInteger)index andIs:(BOOL)is;

@end

@interface KMMessageCell : UITableViewCell

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,weak) id<KMMessageCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *模型
 */
@property (nonatomic,strong)List *model;


@end
