//
//  KMDeviceSettingDetailBodyVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/11.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMDeviceSettingDetailBodyVC : UIViewController

@property (nonatomic, copy) NSString *imei;

/**
 *  设备类型
 */
@property(nonatomic, copy) NSString  *type;
/**
 *  是否通过3Dtouch打开
 */
@property(nonatomic,assign)int is3DTouchLoad;
@end
