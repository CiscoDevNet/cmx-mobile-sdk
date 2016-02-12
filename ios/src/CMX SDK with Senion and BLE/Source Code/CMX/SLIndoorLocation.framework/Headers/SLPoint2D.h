//
//  SLPoint2D.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * SLPoint2D is used to give a location in a metric coordinate system.
 */
@interface SLPoint2D : NSObject

/**
 Constructor.
 @param x_ x-coordinate in meters.
 @param y_ y-coordinate in meters.
 */
- (id) initWithX:(double)x_ andY:(double)y_;

/**
 Constructor.
 @param point
 */
- (id) initWithSLPoint2D:(SLPoint2D*)point;

@property (nonatomic) double x; /**< x-coordinate in meters. */
@property (nonatomic) double y; /**< y-coordinate in meters. */

@end
