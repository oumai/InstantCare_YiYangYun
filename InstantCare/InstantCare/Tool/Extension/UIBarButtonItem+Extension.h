//
//  UIBarButtonItem+Extension.h
//  InstantCare
//
//  Created by xinhuakangmei on 2016/11/7.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

+ (instancetype)itemWithImage:(NSString *)image hightImage:(NSString *)hightImage target:(id)target action:(SEL)action;

+(instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+(instancetype)itemWithImage2:(NSString *)image hightImage:(NSString *)hightImage target:(id)target action:(SEL)action;

@end
