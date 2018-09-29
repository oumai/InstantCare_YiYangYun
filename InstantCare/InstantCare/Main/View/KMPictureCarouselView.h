//
//  KMPictureCarouselView.h
//  InstantCare
//
//  Created by bruce-zhu on 15/11/30.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KMPictureCarouselViewDelegate <NSObject>

@optional
/**
 *  点击图片事件
 *
 *  @param index 当前图片的序号
 */
- (void)BannerViewDidClicked:(NSUInteger)index;

@end

// 图片轮播
@interface KMPictureCarouselView : UIView

@property (nonatomic, weak) id<KMPictureCarouselViewDelegate> delegate;

- (instancetype)initWithImages:(NSArray *)images
                         width:(CGFloat)width
                        height:(CGFloat)height
                  timeInterval:(CGFloat)timeInterval;

@end
