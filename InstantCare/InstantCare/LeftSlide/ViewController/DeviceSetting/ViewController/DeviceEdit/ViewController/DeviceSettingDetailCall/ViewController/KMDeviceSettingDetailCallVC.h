//
//  KMDeviceSettingDetailCallVC.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/11.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,DeviceType)
{
    DeviceType_NO = 0,
    DeviceType_8000 ,
    DeviceType_8010 ,
    DeviceType_8020 ,
};

/**
 *  拨号设定详情页面
 */
@interface KMDeviceSettingDetailCallVC : UIViewController

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
