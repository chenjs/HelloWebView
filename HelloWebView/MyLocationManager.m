//
//  MyLocationManager.m
//  HelloWebView
//
//  Created by chenjs on 13-6-30.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "MyLocationManager.h"
#import "CSqlite.h"

@implementation MyLocationManager {
    CLLocationManager *locationManager;
    CLLocation *location;
    NSError *lastLocationError;
    BOOL isUpdatingLocation;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL isPerformingReverseGeocoding;
    NSError *lastGeocodingError;
    
    CSqlite *sqlite;
}

- (id)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        sqlite = [[CSqlite alloc] init];
        [sqlite openSqlite];
    }
    return self;
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        //locationManager.desiredAccuracy = 50;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
        isUpdatingLocation = YES;
        
        [self performSelector:@selector(didTimeout) withObject:nil afterDelay:60];
    } else {
        [self notifyAddressUpdated];
    }
}

- (void)stopLocationManager
{
    if (isUpdatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeout) object:nil];
        
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        isUpdatingLocation = NO;
    }
}

- (void)didTimeout
{
    NSLog(@"Timeout !!!");
    
    [self stopLocationManager];
    
    if (location == nil) {
        lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
    }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@%@%@ %@",
            (thePlacemark.locality != nil) ? thePlacemark.locality : @"",
            (thePlacemark.thoroughfare != nil) ? thePlacemark.thoroughfare : @"",
            (thePlacemark.subThoroughfare != nil) ? thePlacemark.subThoroughfare : @"",
            (thePlacemark.name != nil) ? thePlacemark.name : @""];
}

- (void)startGetLocation
{
    if (isUpdatingLocation) {
        [self stopLocationManager];
    }

    location = nil;
    lastLocationError = nil;
    placemark = nil;
    lastGeocodingError = nil;
    
    [self startLocationManager];
}

- (void)stopGetLocation
{
    if (isUpdatingLocation) {
        [self stopLocationManager];
    }
}


-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(yGps.latitude*10);
    TenLog = (int)(yGps.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
    //NSLog(sql);
    sqlite3_stmt* stmtL = [sqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
    }
    
    yGps.latitude = yGps.latitude+offLat*0.0001;
    yGps.longitude = yGps.longitude + offLog*0.0001;
    return yGps;
}

-(CLLocation *)zzTransLocation:(CLLocation *)gpsLocation
{
    CLLocationCoordinate2D coordinate = gpsLocation.coordinate;
    CLLocationCoordinate2D zzCoordinate = [self zzTransGPS:coordinate];
    CLLocation *zzLocation = [[CLLocation alloc] initWithLatitude:zzCoordinate.latitude longitude:zzCoordinate.longitude];
    
    return zzLocation;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
    if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    lastLocationError = error;
    
    [self stopLocationManager];
    
    [self notifyAddressUpdated];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"New Location: %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0f) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (location != nil) {
        distance = [newLocation distanceFromLocation:location];
    }
    
    if (location == nil || newLocation.horizontalAccuracy < location.horizontalAccuracy) {
        location = newLocation;
        lastLocationError = nil;
        
        [self notifyAddressUpdated];
        
        if (distance > 1.0) {
            isPerformingReverseGeocoding = NO;
        }
        
        if (newLocation.horizontalAccuracy < locationManager.desiredAccuracy) {
            NSLog(@"We are done");
            [self stopLocationManager];
            
            /*
             if (distance > 0) {
             isPerformingReverseGeocoding = NO;
             }
             */
        }
        
        if (!isPerformingReverseGeocoding) {
            
            NSLog(@"*** Going to Geocoding ...");
            
            isPerformingReverseGeocoding = YES;
            //[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [geocoder reverseGeocodeLocation:[self zzTransLocation:location] completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                
                lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                } else {
                    placemark = nil;
                }
                
                isPerformingReverseGeocoding = NO;
                [self notifyAddressUpdated];
            }];
            
        }
    } else if (distance < 1.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"Force done");
            [self stopLocationManager];
        
            [self notifyAddressUpdated];
        }
    }
}

- (void)notifyAddressUpdated
{
    NSString *error = nil;
    NSString *address = @"";
    CLLocationCoordinate2D coordinate;
    
    if (location != nil) {
        coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        if (placemark != nil) {
            address = [self stringFromPlacemark:placemark];
        } else {
            address = @"";
        }
        
    } else {
        if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied) {
                error = @"当前程序已被禁止使用定位服务.";
            } else {
                error = @"获取位置失败.";
            }
        } else {
            if (![CLLocationManager locationServicesEnabled]) {
                error = @"本机未启用定位服务.";
            } else {
                ;
            }
        }
    }
    
    [self.delegate onLocationUpdated:address coornidate:coordinate error:error];
}



@end
