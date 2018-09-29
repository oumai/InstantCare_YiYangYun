//
//  KMBSModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMBSModel.h"
#import "MJExtension.h"
@implementation KMBSModel

+ (void)load {
    [KMBSModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMBSDetailModel"
                 };
    }];
}

@end

@implementation KMBSDetailModel

@end

