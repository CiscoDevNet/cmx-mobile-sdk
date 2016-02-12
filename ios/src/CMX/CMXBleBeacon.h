//
//  CMXBleBeacon.h
//  CMX
//
//  Created by Abhishek Bhattacharyya on 5/30/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXBleBeacon
 * Defines The beacon uuid,major,minor,mfgid,calrssi,floorid,x-y-z coordinate,beacone name, type and message.
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXBleBeacon
 *  @abstract Defines a Bluetooth Beacon.
 */


@interface CMXBleBeacon : NSObject<NSCoding>

/*!
 *  @property uuid  UUID of the Beacon.
 */
@property (nonatomic, strong, readonly) NSString *uuid;

/*!
 *  @property major Major Number of the beacon.
 */
@property (nonatomic, strong, readonly) NSString *major;

/*!
 *  @property minor Minor Number of the beacon.
 */
@property (nonatomic, strong, readonly) NSString *minor;

/*!
 *  @property mfgId Manufacturer Id of the beacon.Can be vacant.
 */
@property (nonatomic, strong, readonly) NSString *mfgId;

/*!
 *  @property calRssi RSSI of the beacon.Can be vacant.
 */
@property (nonatomic, strong, readonly) NSString *calRssi;

/*!
 *  @property floorId Floor Identifier where the beacon is placed.
 */
@property (nonatomic, strong, readonly) NSString *floorId;

/*!
 *  @property zoneId Zone Identifier where the beacon is placed.
 */
@property (nonatomic, strong, readonly) NSString *zoneId;

/*!
 *  @property xCord XCoordinate where the beacon is placed.
 */
@property (nonatomic, strong, readonly) NSString *xCord;

/*!
 *  @property yCord YCoordinate where the beacon is placed.
 */
@property (nonatomic, strong, readonly) NSString *yCord;

/*!
 *  @property zCord ZCoordinate where the beacon is placed.Can be vacant.
 */
@property (nonatomic, strong, readonly) NSString *zCord;

/*!
 *  @property bleBeaconName Specific name assigned to the bleBeacon.Can be vacant.
 */
@property (nonatomic, strong, readonly) NSString *bleBeaconName;

/*!
 *  @property bleBeaconType  Specific type assigned to the bleBeacon.Can be vacant.
 */
@property (nonatomic, strong, readonly) NSString *bleBeaconType;

/*!
 *  @property regionIdentifier regionId to be used by the CMX SDK for beacon monitoring.
 *
 */
@property (nonatomic, strong, readonly) NSString *regionIdentifier;

/*!
 *  @property message Welcome message to be displayed when the beacon is first detected.
 *                                                  
 */
@property (nonatomic, strong, readonly) NSString *message;



/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object as a CMXBanner instance.
 *
 *  @return A new object.
 */
+ (CMXBleBeacon *)modelObjectWithDictionary:(NSDictionary *)dict;

/*!
 *  @abstract Init an object from a dictionary representation.
 *
 *  @discussion Sets the imageId, imageType, venueId, zoneId from the dictionary.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return Current instance object.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/*!
 *  Returns The dictionary representation of the current object.
 *
 *  @return The dictionary representation of the current object.
 */
- (NSDictionary *)dictionaryRepresentation;

@end
