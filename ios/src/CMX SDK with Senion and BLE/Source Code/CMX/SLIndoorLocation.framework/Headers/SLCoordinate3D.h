//
//  SLCoordinate3D.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//
//

#import "SLCoordinate2D.h"

/**
 This class contains a geographical coordinate using the WGS 84 reference frame including floor number.
 */
@interface SLCoordinate3D : SLCoordinate2D

/**
 Constructor.
 @param latitude_ Latitude in degrees. Positive value is north of the equator, negative south.
 @param longitude_ Longitude in degrees. Positive value is east of the meridian, negative west.
 @param floorNr_ Floor number.
 */
- (id) initWithLatitude:(double)latitude_ andLongitude:(double)longitude_ andFloorNr:(NSInteger)floorNr_;

@property (nonatomic) NSInteger floorNr; /**< Floor number*/

@end
