//
//  SLPoint3D.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import "SLPoint2D.h"

/**
 * SLPoint3D is used to give a location in a metric coordinate system with floor number.
 */
@interface SLPoint3D : SLPoint2D

/**
 Constructor.
 @param x_ x-coordinate in meters.
 @param y_ y-coordinate in meters.
 @param floorNr_ Floor number.
 */
- (id) initWithX:(double)x_ andY:(double)y_ andFloorNr:(NSInteger)floorNr_;

/**
 Constructor.
 @param point
 @param floorNr_ Floor number.
 */
- (id) initWithSLPoint2D:(SLPoint2D*)point andFloorNr:(NSInteger)floorNr_;

/**
 Constructor.
 @param point
 */
- (id) initWithSLPoint3D:(SLPoint3D*)point;

@property (nonatomic) NSInteger floorNr; /**< Floor number */

@end
