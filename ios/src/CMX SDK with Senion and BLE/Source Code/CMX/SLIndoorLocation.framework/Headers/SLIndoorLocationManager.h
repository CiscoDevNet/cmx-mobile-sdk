//
//  SLIndoorLocationManager.h
//  SLIndoorLocationManager
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLIndoorLocationManagerDelegate.h"
#import "SLGeofencing.h"

/** \mainpage SLIndoorLocation
 *
 * \section intro_sec Introduction
 *
 * SLIndoorLocation is a positioning framework intended to be a sub application in a smart phone application. 
 * The framework is given a map and a start position in the map. When the user moves around in the building,
 * position and heading estimates are returned to the SLIndoorLocation delegate. All positions going to or 
 * from SLIndoorLocation is in global latitude and longitude.
 *
 * \section changelog_sec Changelog
 *
 * See the \ref changelog for details.
 *
 * \section brief_over_sec Brief Class Overview
 * SLIndoorLocationManager specifies the positioning interactions. Initiation, starting the positioning,
 * ending the positioning, changing the user position and step length, all is specified there. 
 *
 * SLIndoorLocationManagerDelegate shows the two functions the SLIndoorLocation framework returns. The
 * first is a function that is called by the SLIndoorLocation object when the position of the user has 
 * been updated. The position is provided with an uncertainty. 
 * The second function is called by the SLIndoorLocation object when the heading of the user has been
 * updated.
 *
 * \section example Location Updates
 * The following code shows a simple class implementation that uses positioning from the SLIndoorLocation 
 * framework.
 \verbatim
 - (id) init 
 {
    self = [super init];
    if (self != nil) 
    {
        // Init SLIndoorLocationManager
        NSString *mapId = @""; // Obtained from SenionLab
        NSString *customerId = @""; // Obtained from SenionLab
        locationManager = [[SLIndoorLocationManager alloc] initWithMapId:mapId andCustomerId:customerId];
        locationManager.delegate = self;
    }
 
    return self;
 }
 
 // Optional method
 - (void) didFinishLoadingLocation 
 {
    // Positioning loaded
 }
 
 - (void) didFailInternetConnectionWithError:(NSError *)error 
 {
    // Notify the user that internet connection is needed
 }
 
 - (void) didUpdateLocation:(SLCoordinate3D*)location withUncertainty:(double)radius andStatus:(SLLocationStatusType)locationStatus
 {
    // Do something with location
 }
 
 - (void) didUpdateHeading:(double)heading withStatus:(BOOL)status 
 {
    // Do something with heading
 }
 
 // Optional method
 - (void) didFailScanningBT 
 {
    // Notify the user to turn on bluetooth
 }
 
 - (void)dealloc 
 {
    [locationManager stopUpdatingLocation];
 }
 \endverbatim
 *
 * \section geofencing_sec Geofencing
 * To detect when inside a certain area, the SDK has some built in functionality. The following example
 * code shows how to make use of this functionality. It is assumed that the class implements
 * SLGeofencingDelegate and that the variable locationManager
 * is of type SLIndoorLocationManager. Two regions, one in form of a circle and another
 * in form of a rectangle are defined. When entering and leaving these areas, the functions didEnterGeometry
 * and didLeaveGeometry are called. Contact SenionLab if you need help with defining areas of interest.
 * \verbatim
 - (void) setupGeofencing 
 {
    id<SLGeofencing> geofencing = [locationManager getGeofencingManager];
    [geofencing addDelegate:self];
 
    // Define a circle and add to the list of monitored regions
    SLGeometryId *cId = [[SLGeometryId alloc] initWithGeometryId:@"circle"]; // Used to identify region, use a unique name for id.
    SLCoordinate3D *center = [[SLCoordinate3D alloc] initWithLatitude:58.39341485 andLongitude:15.56097329 andFloorNr:3];
    SLCircle* circle = [[SLCircle alloc] initWithId:cId andCenter:center andRadius:5.0];
    [geofencing addGeometry:circle];
 
    // Define a rectangle and add to the list of monitored regions
    SLGeometryId *rId = [[SLGeometryId alloc] initWithGeometryId:@"rectangle"]; // Used to identify region, use a unique name for id.
    SLCoordinate3D *base = [[SLCoordinate3D alloc] initWithLatitude:58.39356799 andLongitude:15.56139250 andFloorNr:3];
    SLCoordinate3D *edge1 = [[SLCoordinate3D alloc] initWithLatitude:58.39353483 andLongitude:15.56130119 andFloorNr:3];
    SLCoordinate3D *edge2 = [[SLCoordinate3D alloc] initWithLatitude:58.39372786 andLongitude:15.56116658 andFloorNr:3];
    SLParallelogram *rect = [[SLParallelogram alloc] initWithId:rId andBase:base andEdge1:edge1 andEdge2:edge2];
    [geofencing addGeometry:rect];
 }
 
 - (void) didEnterGeometry:(id<SLGeometry>)geometry 
 {
    NSLog(@"Entered: %@", [geometry getGeometryId]);
 }
 
 - (void) didLeaveGeometry:(id<SLGeometry>)geometry 
 {
    NSLog(@"Left: %@", [geometry getGeometryId]);
 }
 \endverbatim
 * \section frameworks Needed Frameworks
 * In order to use the SLIndoorLocation framework, the following frameworks need to be added to the project:
 * <ul>
 *  <li>CFNetwork.framework</li>
 *  <li>CoreBluetooth.framework</li>
 *  <li>CoreGraphics.framework</li>
 *  <li>CoreLocation.framework</li>
 *  <li>CoreMotion.framework</li>
 *  <li>Foundation.framework</li>
 *  <li>MobileCoreServices.framework</li>
 *  <li>QuartzCore.framework</li>
 *  <li>Security.framework</li>
 *  <li>SystemConfiguration.framework</li>
 *  <li>UIKit.framework</li>
 *  <li>libxml2.2.dylib</li>
 *  <li>libz.dylib</li>
 *  <li>libsqlite3.0.dylib</li>
 * </ul>
 *
 * Note that methods in this SDK are patented in US8498811B2.
 */


/**
 @interface SLIndoorLocationManager
 SLIndoorLocationManager specifies the positioning interactions. Initiation, starting the positioning,
 ending the positioning, changing the user position and step length, all is specified there.
 */
@interface SLIndoorLocationManager: NSObject <SLIndoorLocationManagerDelegate>

/**
 Init location using map ID and customer ID.
 @param mapId Map id obtained from SenionLab
 @param customerId Customer id obtained from SenionLab
 */
- (id) initWithMapId:(NSString*)mapId andCustomerId:(NSString*)customerId;

/**
 Set delegate class that will receive updates from SLIndoorLocationManager.
 @param delegate_
 */
- (void) setDelegate:(id<SLIndoorLocationManagerDelegate>)delegate_;

/**
 Start location updates if they have previously been stopped with 
 SLIndoorLocationManager::stopUpdatingLocation. This function is 
 automatically called after initialization.
 */
- (void) startUpdatingLocation;

/**
 Stops location updates. To start positioning again, use SLIndoorLocationManager::startUpdatingLocation.
 */
- (void) stopUpdatingLocation;

/**
 Step length in [m] is specified using this function. Since different users have different 
 steplengths, this should be possible to set.
 @param stepLength Step length in meters
 */
- (void) setStepLength:(double)stepLength;

/**
 @returns Current steplength in meters.
 */
- (double) stepLength;

/**
 @returns The map version id of the loaded map.
 */
- (NSString*) getMapVersionId;

/**
 Set if the calibration display popped up by iOS should be shown.
 @param displayCalibration Set to true if the calibration display should be shown, false otherwise.
 */
- (void) shouldDisplayHeadingCalibration:(BOOL)displayCalibration;

/**
 Returns the geofencing manager, used to create alerts when the user enters specific areas.
 */
- (id<SLGeofencing>) getGeofencingManager;

@end