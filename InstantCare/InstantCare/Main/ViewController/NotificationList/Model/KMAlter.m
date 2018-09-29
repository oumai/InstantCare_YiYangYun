//
//  KMAlter.m
//  InstantCare
//
//  Created by mac on 2016/11/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAlter.h"
#import <MJExtension/MJProperty.h>
@implementation KMAlter

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"loc_key":@"loc-key",
             @"loc_args":@"loc-args"
             };
}

//+ (instancetype)alterWithDict:(NSDictionary *)dict
//{
//    KMAlter *alter = [[self alloc]init];
//    alter.loc_key = dict[@"loc-key"];
//    
//    return alter;
//}

@end
