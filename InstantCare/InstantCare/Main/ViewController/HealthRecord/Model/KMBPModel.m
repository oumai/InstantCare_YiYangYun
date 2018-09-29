//
//  KMBPModel.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/14.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMBPModel.h"
#import "MJExtension.h"
@implementation KMBPModel

+ (void)load {
    [KMBPModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMBPDetailModel"
                 };
    }];
}

@end

@implementation KMBPDetailModel

@end
