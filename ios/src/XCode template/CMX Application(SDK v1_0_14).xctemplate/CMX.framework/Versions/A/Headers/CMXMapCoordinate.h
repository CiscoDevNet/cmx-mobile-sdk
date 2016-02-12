//
//  CMXMapCoordinate.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXUnit.h"

/*!
 * @header CMXMapCoordinate 
 * Defines the mapcoordinates (x,y) on a floor for the client location. 
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXMapCoordinate
 *  @abstract Define 2 dimensional location coordinate in map.
 */
@interface CMXMapCoordinate : NSObject <NSCoding>

/*!
 *  @property x X coordinate of the point.
 */
@property (nonatomic, assign, readonly) float x;

/*!
 *  @property y Y coordinate of the point.
 */
@property (nonatomic, assign, readonly) float y;

/*!
 *  @property unit Unit of the coordinate.
 */
@property (nonatomic, assign, readonly) CMXUnit unit;


/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXMapCoordinate *)modelObjectWithDictionary:(NSDictionary *)dict;

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
