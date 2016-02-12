//
//  SLFilterDelegate.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import "SLIndoorLocationEnums.h"
#import "SLCoordinate3D.h"

/**
 Delegate used by SLIndoorLocationManager to receive information from the navigation filter.
 */
@protocol SLFilterDelegate
- (void) didUpdateFilter:(SLCoordinate3D*)pos withStdDev:(double)stdDev andWithStatus:(BOOL)status;
- (void) didUpdateHeading:(double)heading withStatus:(SLLocationStatusType)status;
@optional
- (void) didFailScanningBT;
@end
