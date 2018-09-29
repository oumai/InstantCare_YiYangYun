//
//  UIImageView+SDWebImage.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SDWebImage)

/**
 *  根据IMEI加载网络图片
 *
 *  @param imei 设备IMEI
 */
- (void)sdImageWithIMEI:(NSString *)imei;

- (void)sdImageWithAccount:(NSString *)account
                      IMEI:(NSString *)imei;

- (void)sdImageWithStringRUL:(NSString *)stringURL;

- (void)sdImageWithStringRUL:(NSString *)stringURL placeholderImage:(NSString *)placeholderImage;

@end
