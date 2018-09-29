//
//  KMLocationManager.h
//  3GSW
//
//  Created by MissionHealth on 15/10/8.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^KMGeocodeCompletionHandler)(NSString *address);
typedef void (^KMGeocodeLocationCompletionHandler)(CLLocation* location);

@interface KMLocationManager : NSObject

/// 存放解析好的地址
@property (nonatomic, copy, readonly) NSString *address;

+ (instancetype)locationManager;

//反地理编码：经纬度坐标->地名
- (void)startLocationWithLocation:(CLLocation *)location resultBlock:(KMGeocodeCompletionHandler)addressBlock;

//地理编码：地名—>经纬度坐标
- (void)geocodeAddress:(NSString*)address complete:(KMGeocodeLocationCompletionHandler)completionBlock;

@end
