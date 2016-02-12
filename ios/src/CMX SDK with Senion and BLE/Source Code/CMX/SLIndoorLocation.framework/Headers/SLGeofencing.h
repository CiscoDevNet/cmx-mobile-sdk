//
//  SLGeofencing.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLGeofencingDelegate.h"

/**
 @protocol SLGeofencing
 The SLGeofencing protocol is used by classes that detects when certain areas are entered/left.
 */

@protocol SLGeofencing <NSObject>

/**
 Use this method to subscribe to updates when entering leaving monitored areas.
 @param delegate
 */
- (void) addDelegate:(id<SLGeofencingDelegate>)delegate;

/**
 Unsubscribe from notifications.
 @param delegate
 */
- (void) removeDelegate:(id<SLGeofencingDelegate>)delegate;

/**
 Add an area that should be monitored.
 @param geometry
 */
- (void) addGeometry:(id<SLGeometry>)geometry;

/**
 Add an array of areas that should be monitored.
 @param geometryArray
 */
- (void) addGeometryArray:(NSArray*)geometryArray;

/**
 Remove an area that should not be monitored anymore.
 @param geometry
 */
- (void) removeGeometry:(id<SLGeometry>)geometry;

/**
 Remove an array of areas that should not be monitored anymore.
 @param geometryArray
 */
- (void) removeGeometryArray:(NSArray*)geometryArray;

/**
 Remove all areas that was monitored.
 */
- (void) clearGeometryList;

@end
