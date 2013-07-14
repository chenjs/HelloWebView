//
//  MyLocationManager.h
//  HelloWebView
//
//  Created by chenjs on 13-6-30.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol MyLocationManagerDelegate <NSObject>

- (void)onLocationUpdated:(NSString *)address coornidate:(CLLocationCoordinate2D)locationCoordinate error:(NSString *)errorMsg;

@end


@interface MyLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<MyLocationManagerDelegate> delegate;

- (void)startGetLocation;
- (void)stopGetLocation;


@end
