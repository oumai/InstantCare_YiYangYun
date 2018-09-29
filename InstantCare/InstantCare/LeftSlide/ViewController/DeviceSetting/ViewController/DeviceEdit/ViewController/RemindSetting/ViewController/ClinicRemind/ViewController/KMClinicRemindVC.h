//
//  KMClinicRemindVC.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  回诊提醒，吃药提醒
 */
@interface KMClinicRemindVC : UIViewController

@property (nonatomic, copy) NSString *imei;

/**
 *  字符串
 *  01: 吃藥
 *  02: 回診
 *  04: 自定義
 */
@property (nonatomic, copy) NSString *key;

@property(nonatomic,assign)NSString * type;

@end
