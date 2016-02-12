//
//  SLIndoorLocationManagerDelegate.h
//  SLIndoorLocationManager
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLIndoorLocationEnums.h"
#import "SLCoordinate3D.h"

@class SLIndoorLocationManager;

/**
 The delegate of the SLIndoorLocationManager must have two functions specified.
 The first one called SLIndoorLocationManagerDelegate::locationManager:didUpdateLocation:withUncertainty: receives the estimated 
 user location with a radius describing the uncertainty circle around the position. The location 
 is specified using SLCoordinate2D. The other function is SLIndoorLocationManagerDelegate::locationManager:didUpdateHeading:withStatus:
 and receives the estimated heading of the user. If the status returned is "NO", the compass 
 needs to be recalibrated by moving it in a figure 8 movement. 
 */
@protocol SLIndoorLocationManagerDelegate <NSObject>
/** 
 Returns a reference to the manager and the longitude/latitude of the user with an uncertainty radius (meters) and status (true=confirmed, false=unconfirmed).
 */
- (void) didUpdateLocation:(SLCoordinate3D*)location withUncertainty:(double)radius andStatus:(SLLocationStatusType)locationStatus;

/** 
 Returns a reference to the manager and a heading (can be used to rotate the map), status 
 indicates if the compass need calibration with figure 8 movement (as in the compass application).
 */
- (void) didUpdateHeading:(double)heading withStatus:(BOOL)status;

/**
 Called if internet connection is not working.
 */
- (void) didFailInternetConnectionWithError:(NSError *)error;

@optional
- (void) didFinishLoadingLocation;
- (void) didFailScanningBT;

@end
