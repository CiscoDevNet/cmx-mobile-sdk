//
//  CMXClientConfiguration.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXClientConfiguration
 * Configures a CMX Client instance including the cloud server URL it is supposed to connect to.
 * @copyright Cisco Systems
 */


/*!
 * @class CMXClientConfiguration
 * @abstract Configure a CMX client instance
 */
@interface CMXClientConfiguration : NSObject

/*!
 *  @property serverURL
 *              URL of the CMX cloud server.
 */
@property (nonatomic,strong) NSURL *serverURL;

/*!
 *  @abstract Creates a client instance using the preset values.
 *
 *  @return An initialized configuration object or nil if the object couldn't be created.
 */
+(CMXClientConfiguration*) defaultConfiguration;

/*!
 *  @abstract Creates an instance using the values found in the specified .plist file.
 *
 *  @param path The path of the specified file.
 *
 *  @return An initialized configuration object or nil if the object couldn't be created.
 */
+(CMXClientConfiguration*) configurationWithContentsOfFile:(NSString*)path;


@end
