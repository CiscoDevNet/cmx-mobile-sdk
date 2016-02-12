///
//  CMXGeoCoordinate.h
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXUnit.h"

/*!
 * @header CMXGeoCoordinate
 * Defines the geocoordinates (latitude,longitude) for the client location. This will work only when GPS markers
 * are placed on the Prime Infrastructure map of the floor in which the client is located. The units are in decimal
 * degrees.
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXGeoCoordinate
 *  @abstract Define 2 dimensional geographical coordinates.
 */
@interface CMXGeoCoordinate : NSObject <NSCoding>

/*!
 *  @property latitude
 */
@property (nonatomic, assign, readonly) float latitude;

/*!
 *  @property longitude
 */
@property (nonatomic, assign, readonly) float longitude;



/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXGeoCoordinate *)modelObjectWithDictionary:(NSDictionary *)dict;

/*!
 *  @abstract Init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return Current instance object.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/*!
 *  @abstract Returns The dictionary representation of the current object.
 *
 *  @return The dictionary representation of the current object.
 */
- (NSDictionary *)dictionaryRepresentation;

@end

