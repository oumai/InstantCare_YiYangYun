//
//  KMCallView.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KMCallViewType)
{
    KM_CALL_TYPE_SPEED_CALL = 0,        // 快速拨号
    KM_CALL_TYPE_LISTION_CALL = 1       // 环境监听
};

@protocol KMCallViewDelegate <NSObject>

@optional
- (void)KMCallViewBtnDidClicked:(KMCallViewType)button;

@end

// 弹出拨号界面
@interface KMCallView : UIView

@property (nonatomic, weak) id<KMCallViewDelegate> delegate;

/**
 *  更新用户名和电话号码
 *
 *  @param name  用户名(可能没有)
 *  @param phone 电话号码
 */
- (void)updateName:(NSString *)name
             Phone:(NSString *)phone;

@end
