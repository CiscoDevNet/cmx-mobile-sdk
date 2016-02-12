//
//  CMXNetwork.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Define a network.
 */
@interface CMXNetwork : NSObject <NSCoding>

/**
 *  SSID of the network.
 */
@property (nonatomic, strong, readonly) NSString *ssid;

/**
 *  Password of the network.
 */
@property (nonatomic, strong, readonly) NSString *password;

/**
 *  Alloc and init an object from a dictionary representation.
 *
 *  @param dict The dictionary representation of the object.
 *
 *  @return A new object.
 */
+ (CMXNetwork *)modelObjectWithDictionary:(NSDictionary *)dict;

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
