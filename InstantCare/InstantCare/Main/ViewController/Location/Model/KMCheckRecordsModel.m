//
//  KMCheckRecordsModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCheckRecordsModel.h"
#import "MJExtension.h"
@implementation KMCheckRecordsModel

+ (void)load {
    [KMCheckRecordsModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMCheckRecordsDetailModel"
                 };
    }];
}

@end

@implementation KMCheckRecordsDetailModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _btnSelectState = -1;
    }
    
    return self;
}

@end
