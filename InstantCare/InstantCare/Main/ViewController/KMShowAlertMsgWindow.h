//
//  KMShowAlertMsgWindow.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/22.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMShowAlertMsgWindow : UIWindow

+ (instancetype)sharedInstance;
- (void)showMsg:(NSString *)msg;
- (void)hide;

@end
