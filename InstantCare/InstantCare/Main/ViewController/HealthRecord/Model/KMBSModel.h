//
//  KMBSModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBSModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end


@interface KMBSDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long long bsTime;

@property (nonatomic, assign) long glu;

@property (nonatomic, assign) long long createDate;

@end
