//
//  CMXBanner.h
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXBanner
 * Holds the information of a banner displayed through the Banner View Controller. 
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXBanner
 *  @abstract Class that holds information of a banner.
 */
@interface CMXBanner : NSObject <NSCoding>

/*!
 *  @property imageId
 *            Id of the banner's image.
 */
@property (nonatomic, strong, readonly) NSString *imageId;

/*!
 * @property imageType
 *           Image type.
 */
@property (nonatomic, strong, readonly) NSString *imageType;

/*!
 *  @property venueId
 *            Id of the venue.
 */
@property (nonatomic, strong, readonly) NSString *venueId;

/*!
 *  @property zoneId
 *            Id of the zone.
 */
@property (nonatomic, strong, readonly) NSString *zoneId;

/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object as a CMXBanner instance.
 *
 *  @return A new object.
 */
+ (CMXBanner *)modelObjectWithDictionary:(NSDictionary *)dict;

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
