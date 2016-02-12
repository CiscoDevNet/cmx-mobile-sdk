//
//  CMXClientLocation.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMXMapCoordinate;


/**
 *  Define location informations of the client.
 */
@interface CMXClientLocation : NSObject <NSCoding>

/**
 *  Id of the venue where the client is located.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/**
 *  Id of the floor where the client is located.
 */
@property (nonatomic, strong, readonly) NSString *floorId;

/**
 *  Coordinate of the client on the map.
 */
@property (nonatomic, strong, readonly) CMXMapCoordinate *mapCoordinate;
 
/**
 *  Id of the client's device.
 */
@property (nonatomic, strong, readonly) NSString *deviceId;

/**
 *  Id of the zone where the client is located.
 */
@property (nonatomic,strong, readonly) NSString *zoneId;


/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXClientLocation *)modelObjectWithDictionary:(NSDictionary *)dict;

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
