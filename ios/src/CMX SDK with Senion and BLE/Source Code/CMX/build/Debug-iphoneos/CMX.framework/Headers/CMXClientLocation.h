//
//  CMXClientLocation.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMXMapCoordinate;
@class CMXGeoCoordinate;

/*!
 * @header CMXClientLocation
 * Defines information elements which will identify a client's location. Includes venueId, floorId,zoneId,
 * mapcoordinates,geocoordinates,deviceId
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXClientLocation
 *  @abstract Define location information elements for the client.
 */
@interface CMXClientLocation : NSObject <NSCoding>

/*!
 * @property venueId
 *              Id of the venue where the client is located.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/*!
 * @property floorId
 *              Id of the floor where the client is located.
 */
@property (nonatomic, strong, readonly) NSString *floorId;

/*!
 * @property mapCoordinate
 *              Coordinate of the client on the map.
 */
@property (nonatomic, strong, readonly) CMXMapCoordinate *mapCoordinate;

/*!
 * @property geoCoordinate
 *              geoLocation of the client on the map.
 */
@property (nonatomic, strong, readonly) CMXGeoCoordinate *geoCoordinate;
 
/*!
 *  @property deviceId
 *              Id of the client's device.
 */
@property (nonatomic, strong, readonly) NSString *deviceId;

/*!
 * @property zoneId
 *              Id of the zone where the client is located.
 */
@property (nonatomic,strong, readonly) NSString *zoneId;

@property (nonatomic,readonly) NSString *lastLocationUpdateTime;


/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *  @discussion Initializes the object with the venueId, floorId, mapCoordinate,geoCoordinate,deviceId and zoneId
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXClientLocation *)modelObjectWithDictionary:(NSDictionary *)dict;

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
