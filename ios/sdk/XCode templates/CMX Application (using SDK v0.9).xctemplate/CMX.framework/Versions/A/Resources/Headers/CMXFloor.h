//
//  CMXFloor.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMXDimension;

/**
 *  Define information about a floor.
 */
@interface CMXFloor : NSObject <NSCoding>

/**
 *  Unique identifier of this floor.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/**
 *  Id of the venue holding this floor.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/**
 *  Dimension of the floor.
 */
@property (nonatomic, strong, readonly) CMXDimension *dimension;

/**
 *  Name of the floor.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXFloor *)modelObjectWithDictionary:(NSDictionary *)dict;

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
