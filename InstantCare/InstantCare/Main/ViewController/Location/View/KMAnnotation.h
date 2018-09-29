//
//  KMAnnotation.h
//  InstantCare
//
//  Created by 朱正晶 on 15/12/14.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KMAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

/**
 *  自定义一个图片属性在创建大头针视图时使用
 */
@property (nonatomic,strong) UIImage *image;

@end
