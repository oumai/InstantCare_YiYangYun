//
//  UIButton+SDWebImage.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "UIButton+SDWebImage.h"
#import "UIButton+WebCache.h"
@implementation UIButton (SDWebImage)

- (void)sdImageWithIMEI:(NSString *)imei {
    [self sdImageWithAccount:member.loginAccount IMEI:imei];
}

- (void)sdImageWithAccount:(NSString *)account
                      IMEI:(NSString *)imei {
    NSString *url = [NSString stringWithFormat:@"%@/%@", account, imei];
    [self sdImageWithStringRUL:url forState:UIControlStateNormal];
}

- (void)sdImageWithStringRUL:(NSString *)stringURL forState:(UIControlState)state {
    [self sdImageWithStringRUL:stringURL forState:state placeholderImage:@"default_photo"];
}

- (void)sdImageWithStringRUL:(NSString *)stringURL forState:(UIControlState)state placeholderImage:(NSString *)placeholderImage {
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/image/head/%@",
                     kServerAddress, stringURL];
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:url]
                              forState:state
                      placeholderImage:[UIImage imageNamed:placeholderImage]];
}

@end
