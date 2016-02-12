//
//  CMXClientConfiguration.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Client configuration
 */
@interface CMXClientConfiguration : NSObject

/**
 *  URL of a CMX server.
 */
@property (nonatomic,strong) NSURL *serverURL;

/**
 *  Creates an instance using the values set in the file named configuration.plist.
 *
 *  @return An initialized configuration object or nil if the object couldn't be created.
 */
+(CMXClientConfiguration*) defaultConfiguration;

/**
 *  Creates an instance using the values found in the specified .plist file.
 *
 *  @param path The path of the specified file.
 *
 *  @return An initialized configuration object or nil if the object couldn't be created.
 */
+(CMXClientConfiguration*) configurationWithContentsOfFile:(NSString*)path;


@end
