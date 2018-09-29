//
//  UIButton+SDWebImage.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SDWebImage)

- (void)sdImageWithIMEI:(NSString *)imei;

- (void)sdImageWithAccount:(NSString *)account
                      IMEI:(NSString *)imei;

- (void)sdImageWithStringRUL:(NSString *)stringURL forState:(UIControlState)state placeholderImage:(NSString *)placeholderImage;

@end
