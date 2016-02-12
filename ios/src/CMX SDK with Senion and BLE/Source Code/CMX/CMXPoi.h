//
//  CMXPOI.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

/*!
 * @header CMXPoi
 * Defines the poi identifier, name, venueid, floorid, points , imagetype and facebook and twitter ids for the poi. 
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXPoi
 *  @abstract Define a Point Of Interest.
 */
@interface CMXPoi : NSObject <NSCoding>

/*!
 *  @property identifier Unique identifier of the poi.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/*!
 *  @property name Name of the poi.
 */
@property (nonatomic, strong, readonly) NSString *name;

/*!
 *  @property venueId Id of the venue where the poi is located.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/*!
 *  @property floorId Id of the floor where the poi is located.
 */
@property (nonatomic, strong, readonly) NSString *floorId;

/*!
 *  @property points Area (array of CMXPoint) representing the poi.
 */
@property (nonatomic, strong, readonly) NSArray *points;

/*!
 *  @property imageType Image type of the poi.
 */
@property (nonatomic,strong, readonly) NSString *imageType;

/*!
 *  @property facebookPlaceId Place id in Facebook Graph API.
 */
@property (nonatomic,strong, readonly) NSString *facebookPlaceId;

/*!
 *  @property twitterPlaceId Place id in Twitter.
 */
@property (nonatomic,strong, readonly) NSString *twitterPlaceId;


/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXPoi *)modelObjectWithDictionary:(NSDictionary *)dict;

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
