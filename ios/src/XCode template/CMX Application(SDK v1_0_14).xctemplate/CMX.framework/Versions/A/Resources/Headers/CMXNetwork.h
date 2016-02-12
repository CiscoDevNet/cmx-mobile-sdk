//
//  CMXNetwork.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXNetwork 
 * Defines the wireless network as a ssid and password combination. 
 * @copyright Cisco Systems
 */


/*!
 * @class CMXNetwork
 * @abstract Wireless network ssid and password definition.
 */
@interface CMXNetwork : NSObject <NSCoding>

/*!
 * @property ssid  SSID of the network.
 */
@property (nonatomic, strong, readonly) NSString *ssid;

/*!
 *  @property password Password of the network.
 */
@property (nonatomic, strong, readonly) NSString *password;

/*!
 *  @abstract Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXNetwork *)modelObjectWithDictionary:(NSDictionary *)dict;

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
