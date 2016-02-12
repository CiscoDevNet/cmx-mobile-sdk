//
//  CMXMapCoordinate.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXUnit.h"

/**
 *  Define 2 dimensional coordinate in map.
 */
@interface CMXMapCoordinate : NSObject <NSCoding>

/**
 *  X coordinate of the point.
 */
@property (nonatomic, assign, readonly) float x;

/**
 *  Y coordinate of the point.
 */
@property (nonatomic, assign, readonly) float y;

/**
 *  Unit of the coordinate.
 */
@property (nonatomic, assign, readonly) CMXUnit unit;


/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXMapCoordinate *)modelObjectWithDictionary:(NSDictionary *)dict;

/**
 *  Init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return Current instance object.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 *  Returns The dictionary representation of the current object.
 *
 *  @return The dictionary representation of the current object.
 */
- (NSDictionary *)dictionaryRepresentation;

@end
