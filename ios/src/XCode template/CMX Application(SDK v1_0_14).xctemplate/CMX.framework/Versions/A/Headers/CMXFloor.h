//
//  CMXFloor.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMXDimension;

/*!
 * @header CMXFloor 
 * Defines the floor identifier, name, venue id and the floor dimensions
 * @copyright Cisco Systems
 */


/*!
 * @class CMXFloor
 * @abstract Define information about a floor.
 */
@interface CMXFloor : NSObject <NSCoding>

/*!
 *  @property identifier
 *            Unique identifier of this floor.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/*!
 *  @property venueId
 *              Id of the venue holding this floor.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/*!
 *  @property dimension
 *              Dimension of the floor.
 */
@property (nonatomic, strong, readonly) CMXDimension *dimension;

/*!
 *  @property name
 *              Name of the floor.
 */
@property (nonatomic, strong, readonly) NSString *name;

/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXFloor *)modelObjectWithDictionary:(NSDictionary *)dict;

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
