//
//  CMXVenues.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMXWifiConnectionMode.h"

/*!
 * @header CMXVenue 
 * Defines the venue in terms of the identifier, name . street address, networks at the venue , location update interval and
 * wifimode.
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXVenue
 *  @abstract Define a venue
 */
@interface CMXVenue : NSObject <NSCoding>

/*!
 *  @property identifier 
 *              Unique identifier of the venue.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/*!
 *  @property name 
 *              Name of the venue.
 */
@property (nonatomic, strong, readonly) NSString *name;

/*!
 *  @property streetAddress
 *              Street address of the venue.
 */
@property (nonatomic, strong, readonly) NSString *streetAddress;

/*!
 *  @property preferredNetworks
 *              Preferred networks of the venue. Ssid and password.
 */
@property (nonatomic, strong, readonly) NSArray *preferredNetworks;

/*!
 *  @property locationUpdateInterval
 *              Location update interval (in seconds).
 */
@property (nonatomic, assign, readonly) NSUInteger locationUpdateInterval;

/*!
 *  @property wifiMode
 *              Wifi connection mode used for the venue.For ios 6 onwards even if it is set to auto it will default to manual.
 *              Apple no longer permits users to set wificonnection programatically.
 */
@property (nonatomic, assign, readonly) CMXWifiConnectionMode wifiMode;


/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXVenue *)modelObjectWithDictionary:(NSDictionary *)dict;

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
