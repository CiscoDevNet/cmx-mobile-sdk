//
//  CMXPOI.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

/**
 *  Define a Point Of Interest.
 */
@interface CMXPoi : NSObject <NSCoding>

/**
 *  Unique identifier of the poi.
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/**
 *  Name of the poi.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Id of the venue where the poi is located.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/**
 *  Id of the floor where the poi is located.
 */
@property (nonatomic, strong, readonly) NSString *floorId;

/**
 *  Area (array of @see CMXPoint) representing the poi.
 */
@property (nonatomic, strong, readonly) NSArray *points;

/**
 *  Image type of the poi.
 */
@property (nonatomic,strong, readonly) NSString *imageType;

/**
 *  Place id in Facebook Graph API.
 */
@property (nonatomic,strong, readonly) NSString *facebookPlaceId;

/**
 *  Place id in Twitter.
 */
@property (nonatomic,strong, readonly) NSString *twitterPlaceId;


/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXPoi *)modelObjectWithDictionary:(NSDictionary *)dict;

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
