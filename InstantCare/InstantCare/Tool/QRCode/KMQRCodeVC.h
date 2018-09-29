//
//  KMQRCodeVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/7.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBXScanViewStyle;

@protocol KMQRCodeVCDelegate <NSObject>

@optional
- (void)KMQRCodeVCResult:(NSString *)code barCodeType:(NSString *)type;

@end

@interface KMQRCodeVC : UIViewController

@property (nonatomic, strong) LBXScanViewStyle *style;
@property (nonatomic, weak) id<KMQRCodeVCDelegate> delegate;

@end
