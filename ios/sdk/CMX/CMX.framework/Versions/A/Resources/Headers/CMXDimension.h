//
//  CMXDimension.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXUnit.h"

/**
 *  Defines 3D dimensions.
 */
@interface CMXDimension : NSObject <NSCoding>

/**
 *  Height.
 */
@property (nonatomic, assign, readonly) float height;

/**
 *  Length.
 */
@property (nonatomic, assign, readonly) float length;

/**
 *  Width.
 */
@property (nonatomic, assign, readonly) float width;

// TODO : unit (pixel, feet) is missing ??
/**
 *  X offset in the map image.
 */
@property (nonatomic, assign, readonly) float offsetX;

// TODO : unit (pixel, feet) is missing ??
/**
 *  Y offset in the map image.
 */
@property (nonatomic, assign, readonly) float offsetY;

/**
 *  Unit of height/length/width.
 */
@property (nonatomic, assign, readonly) CMXUnit unit;

/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXDimension *)modelObjectWithDictionary:(NSDictionary *)dict;

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
