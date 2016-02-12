//
//  CMXPoint.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Class that defines a 2 dimensional point.
 */
@interface CMXPoint : NSObject <NSCoding>

/**
 *  X coordinate of the point.
 */
@property (nonatomic, assign, readonly) float x;

/**
 *  Y coordinate of the point.
 */
@property (nonatomic, assign, readonly) float y;

/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXPoint *)modelObjectWithDictionary:(NSDictionary *)dict;

/**
 *  Init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return Current instance object.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

@end
