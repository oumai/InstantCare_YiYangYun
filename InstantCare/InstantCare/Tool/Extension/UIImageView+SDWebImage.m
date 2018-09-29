//
//  UIImageView+SDWebImage.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "UIImageView+SDWebImage.h"
#import "UIImageView+WebCache.h"
@implementation UIImageView (SDWebImage)

- (void)sdImageWithIMEI:(NSString *)imei {
    [self sdImageWithAccount:member.loginAccount IMEI:imei];
}

- (void)sdImageWithAccount:(NSString *)account
                      IMEI:(NSString *)imei {
    NSString *url = [NSString stringWithFormat:@"%@/%@", account, imei];
    [self sdImageWithStringRUL:url];
}

- (void)sdImageWithStringRUL:(NSString *)stringURL {
    [self sdImageWithStringRUL:stringURL placeholderImage:@"default_photo"];
    //default_photo
}

- (void)sdImageWithStringRUL:(NSString *)stringURL placeholderImage:(NSString *)placeholderImage {
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/image/head/%@",kServerAddress, stringURL];
//    [self sd_setImageWithURL:[NSURL URLWithString:url]
//            placeholderImage:[UIImage imageNamed:placeholderImage]];
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:placeholderImage] options:SDWebImageRefreshCached|SDWebImageRetryFailed];
}

@end
