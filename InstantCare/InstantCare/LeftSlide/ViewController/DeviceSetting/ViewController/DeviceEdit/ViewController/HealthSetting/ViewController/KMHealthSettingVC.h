//
//  KMHealthSettingVC.h
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMHealthSettingVC : UIViewController

/** imei */
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
