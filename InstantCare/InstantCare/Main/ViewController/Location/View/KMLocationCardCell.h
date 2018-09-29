//
//  KMLocationCardCell.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/19.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMLocationCardCell;

@protocol KMLocationCardCellDelegate <NSObject>

@optional
/**
 *  cell中按钮被点击
 *
 *  @param cell  这个cell对象
 *  @param index 按钮, 0 -> 左边按钮; 1 -> 右边按钮
 */
- (void)cellBtnDidClickWithCell:(KMLocationCardCell *)cell btnIndex:(NSInteger)index;

@end

/**
 *  打卡记录Cell
 */
@interface KMLocationCardCell : UITableViewCell

@property (nonatomic, weak) id<KMLocationCardCellDelegate> delegate;

@property (nonatomic, copy) NSString *checkinDate;
@property (nonatomic, copy) NSString *checkOutDate;
/**
 *  左右两个按钮哪个被选中
 *  0 -> 左边按钮
 *  1 -> 右边按钮被选中
 *  其他 -> 没有按钮被选中
 */
@property (nonatomic, assign) NSInteger selectBtnIndex;

@end



