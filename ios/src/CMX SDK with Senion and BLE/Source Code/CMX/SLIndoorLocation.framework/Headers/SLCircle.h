//
//  SLCircle.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLGeometryId.h"
#import "SLCoordinate3D.h"

/**
 @interface SLCircle
 Class used to define a geofencing area in form of a circle.
 The coordinates that needs to be supplied is marked in the figure below.
 \image html circle.jpg
 */
@interface SLCircle : NSObject <SLGeometry>

/**
 Constructor for SLCircle.
 @param geometryId Id used to identify a geometry, make sure that this is unique to be able identify which region that is detected.
 @param center Center of the circle.
 @param radius Radius of the circle in meters.
 */
- (id) initWithId:(SLGeometryId*)geometryId andCenter:(SLCoordinate3D*)center andRadius:(double)radius;

/**
 A hysteresis is used to avoid getting messages about entering/leaving an area to frequently 
 when the user is at the border of the area. The user has to be at the hysteresis distance from 
 the area to be detected as outside. There is a default value in the class, but it can
 be adjusted with this method if necessary.
 @param hysteresis distance in meters.
 */
- (void) setHysteresis:(double)hysteresis;

@end
