//
//  CMXWifiConnectionMode.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Defines Wi-fi connection modes
 */
typedef NS_ENUM(NSUInteger, CMXWifiConnectionMode) {
    /**
     *  Auto connection mode
     */
    AUTO,
    /**
     *  Manual connection mode
     */
    MANUAL,
    /**
     *  Prompt connection mode
     */
    PROMPT
};

/**
 *  Convert connection mode value to string representation.
 *
 *  @param mode a connection mode
 *
 *  @return The string representation of a connection mode
 */
NSString* connectionModeToString(CMXWifiConnectionMode mode);

/**
 *  Convert string representation to connection mode.
 *
 *  @param string a string representation
 *
 *  @return The connection mode of the string
 */
CMXWifiConnectionMode stringToConnectionMode(NSString* string);
