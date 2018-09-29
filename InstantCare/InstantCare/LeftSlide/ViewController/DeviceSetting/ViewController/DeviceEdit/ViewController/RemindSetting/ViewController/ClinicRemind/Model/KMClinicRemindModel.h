//
//  KMClinicRemindModel.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMRemindModel.h"

@interface KMClinicRemindModel : NSObject

/**
 *  回诊提醒
 */
@property (nonatomic, strong) NSArray *clinic;
/**
 *  吃药提醒
 */
@property (nonatomic, strong) NSArray *medical;

@end
