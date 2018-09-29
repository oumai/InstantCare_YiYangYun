//
//  KMStepModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMStepModel : NSObject
@property (nonatomic, strong) NSArray *list;
@end

@interface KMStepDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, assign) long typeid;

@property (nonatomic, assign) long long sTime;

@property (nonatomic, assign) long long eTime;

@property (nonatomic, assign) long weight;

@property (nonatomic, assign) long stepLong;

@property (nonatomic, assign) long steps;

@property (nonatomic, assign) long distance;

@property (nonatomic, assign) long cal;

@property (nonatomic, assign) long long createDate;

@end


