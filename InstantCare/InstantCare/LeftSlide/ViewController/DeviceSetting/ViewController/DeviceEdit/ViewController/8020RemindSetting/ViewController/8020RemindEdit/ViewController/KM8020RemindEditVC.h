//
//  KM8020RemindEditVC.h
//  InstantCare
//
//  Created by km on 16/9/9.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMRemindDetailModel;


typedef NS_ENUM(NSInteger,KM8020RemindEditStatus)
{
    KM8020RemindStatusAdd = 1,
    KM8020RemindStatusEdit
    
};

@interface KM8020RemindEditVC : UITableViewController

/** model */
@property (nonatomic, strong) KMRemindDetailModel *model;

/** 编辑状态 */
@property (nonatomic, assign) KM8020RemindEditStatus editStatus;

/** imei */
@property (nonatomic, copy) NSString *imei;



@end
