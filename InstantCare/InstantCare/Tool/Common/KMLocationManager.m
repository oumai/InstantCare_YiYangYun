//
//  KMLocationManager.m
//  3GSW
//
//  Created by MissionHealth on 15/10/8.
//
//

#import "KMLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKPlacemark.h>

@interface KMLocationManager()

@property (nonatomic, strong) CLGeocoder *geo;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, strong) KMGeocodeCompletionHandler geoBlock;

@end

@implementation KMLocationManager

+ (instancetype)locationManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _geo = [[CLGeocoder alloc] init];
    }

    return self;
}

//location to real address string
- (void)startLocationWithLocation:(CLLocation *)location
                      resultBlock:(KMGeocodeCompletionHandler)addressBlock
{
    [_geo reverseGeocodeLocation:location
               completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                   if (error) {
                       NSLog(@"*** startLocationWithLocation[%f, %f] error: %@",
                             location.coordinate.longitude,
                             location.coordinate.latitude,
                             error);
                       if (addressBlock) {
                           addressBlock(nil);
                       }
                       return;
                   }
                   
                   NSString *realaddress = [[placemarks firstObject] name];
                   self.address = realaddress;
                   if (addressBlock) {
                       addressBlock(realaddress);
                   }
               }];
}

//address string to location

- (void)geocodeAddress:(NSString*)address complete:(KMGeocodeLocationCompletionHandler)completionBlock{
    
    [_geo geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error && placemarks.count == 0){
            NSLog(@"%@ 地址编码失败 %@ ",address,error.localizedDescription);
        }else{
            CLLocation* location = [placemarks firstObject].location;
            
            if(completionBlock){
                completionBlock(location);
            }
        }
    }];
}

@end
