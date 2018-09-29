    //
//  KMCustomRemindEditVC.h
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMRemindModel.h"

typedef  NS_ENUM(NSInteger,remindStatus)
{
    remindStatusAdd = 1,
    remindStatusEdit
};


@interface KMCustomRemindEditVC : UIViewController

@property(nonatomic,strong)KMRemindDetailModel * model;

@property(nonatomic,assign)NSInteger team;

@property(nonatomic,assign)remindStatus stauts;

@property(nonatomic,strong)NSString * imei;

@end
