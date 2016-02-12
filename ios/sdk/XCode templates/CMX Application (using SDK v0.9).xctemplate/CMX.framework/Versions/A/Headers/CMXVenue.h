//
//  CMXVenues.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMXWifiConnectionMode.h"

/**
 *  Define a venue
 */
@interface CMXVenue : NSObject <NSCoding>

/**
 *  Unique identifier of the venue.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/**
 *  Name of the venue.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Street address of the venue.
 */
@property (nonatomic, strong, readonly) NSString *streetAddress;

/**
 *  Preferred networks of the venue.
 */
@property (nonatomic, strong, readonly) NSArray *preferredNetworks;

/**
 *  Location update interval (in seconds).
 */
@property (nonatomic, assign, readonly) NSUInteger locationUpdateInterval;

/**
 *  Wifi connection mode used for the venue.
 */
@property (nonatomic, assign, readonly) CMXWifiConnectionMode wifiMode;


/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXVenue *)modelObjectWithDictionary:(NSDictionary *)dict;

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
