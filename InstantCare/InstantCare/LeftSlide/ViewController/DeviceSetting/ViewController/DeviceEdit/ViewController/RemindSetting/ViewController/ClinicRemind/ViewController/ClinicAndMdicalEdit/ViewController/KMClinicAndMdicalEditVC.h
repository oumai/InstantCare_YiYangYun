//
//  KMClinicAndMdicalEditVC.h
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMRemindModel.h"

@interface KMClinicAndMdicalEditVC : UIViewController

@property(nonatomic,strong)KMRemindDetailModel * model;
@property(nonatomic,assign)NSInteger team;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *key;


@end
