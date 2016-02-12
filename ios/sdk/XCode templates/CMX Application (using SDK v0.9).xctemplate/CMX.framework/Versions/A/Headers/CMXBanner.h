//
//  CMXBanner.h
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class that holds information of a banner.
 */
@interface CMXBanner : NSObject <NSCoding>

/**
 *  Id of the banner's image.
 */
@property (nonatomic, strong, readonly) NSString *imageId;

/**
 *  Image type.
 */
@property (nonatomic, strong, readonly) NSString *imageType;

/**
 *  Id of the venue.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/**
 *  Id of the zone.
 */
@property (nonatomic, strong, readonly) NSString *zoneId;

/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXBanner *)modelObjectWithDictionary:(NSDictionary *)dict;

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
