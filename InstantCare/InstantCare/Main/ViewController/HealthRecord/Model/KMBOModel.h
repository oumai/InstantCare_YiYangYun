//
//  KMBOModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBOModel : NSObject
@property (nonatomic, strong) NSArray *list;
@end

@interface KMBODetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long long oxyTime;

@property (nonatomic, assign) long puls;

@property (nonatomic, assign) long spo2;

@property (nonatomic, assign) long long createDate;

@end
