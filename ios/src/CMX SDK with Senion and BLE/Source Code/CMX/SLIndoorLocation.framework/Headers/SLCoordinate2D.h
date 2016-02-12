//
//  SLCoordinate2D.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//
//

#import <Foundation/Foundation.h>
/**
 This class contains a geographical coordinate using the WGS 84 reference frame.
 */
@interface SLCoordinate2D : NSObject

/**
 Constructor.
 @param latitude_ Latitude in degrees. Positive value is north of the equator, negative south.
 @param longitude_ Longitude in degrees. Positive value is east of the meridian, negative west.
 */
- (id) initWithLatitude:(double)latitude_ andLongitude:(double)longitude_;

@property (nonatomic) double latitude; /**< Latitude in degrees. Positive value is north of the equator, negative south.*/
@property (nonatomic) double longitude; /**< Longitude in degrees. Positive value is east of the meridian, negative west.*/

@end
