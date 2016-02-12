//
//  CMXDimension.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXUnit.h"

/*!
 * @header CMXDimension
 * Defines 3D dimensions (length,height,width) for map image
 * @copyright Cisco Systems
 */


/*!
 * @class CMXDimension
 * @abstract Defines 3D dimensions.
 */
@interface CMXDimension : NSObject <NSCoding>

/*!
 *  @property height
 */
@property (nonatomic, assign, readonly) float height;

/*!
 *  @property length
 */
@property (nonatomic, assign, readonly) float length;

/*!
 *  @property width
 */
@property (nonatomic, assign, readonly) float width;

// TODO : unit (pixel, feet) is missing ??
/*!
 *  @property offsetX
 *                X offset in the map image.
 */
@property (nonatomic, assign, readonly) float offsetX;

// TODO : unit (pixel, feet) is missing ??
/*!
 *  @property offsetY
 *               Y offset in the map image.
 */
@property (nonatomic, assign, readonly) float offsetY;

/*!
 * @property unit
 *              Unit of height/length/width.
 */
@property (nonatomic, assign, readonly) CMXUnit unit;

/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXDimension *)modelObjectWithDictionary:(NSDictionary *)dict;

/*!
 *  @abstract Init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return Current instance object. Sets length, height , width, offsetX, offsetY, unit in the instance object
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/*!
 *  @abstract Returns The dictionary representation of the current object.
 *
 *  @return The dictionary representation of the current object.
 */
- (NSDictionary *)dictionaryRepresentation;

@end
