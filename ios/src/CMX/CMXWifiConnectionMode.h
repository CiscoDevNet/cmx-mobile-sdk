//
//  CMXWifiConnectionMode.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXWifiConnectionMode
 * Ios6 onwards this will default to manual even if the user sets it to auto.
 * @copyright Cisco Systems
 */

/*!
 * @abstract Defines Wi-fi connection modes. 
 * @discussion ios 6 onwards this will default to manual even if the user sets it to auto.
 */
typedef NS_ENUM(NSUInteger, CMXWifiConnectionMode) {
    /*!
     * No Connection mode
     */
    NONE,
    /*!
     *  Auto connection mode
     */
    AUTO,
    /*!
     *  Manual connection mode
     */
    MANUAL,
    /*!
     *  Prompt connection mode
     */
    PROMPT
};

/*!
 *  @abstract Convert connection mode value to string representation.
 *
 *  @param mode a connection mode
 *
 *  @return The string representation of a connection mode
 */
NSString* connectionModeToString(CMXWifiConnectionMode mode);

/*!
 *  @abstract Convert string representation to connection mode.
 *
 *  @param string a string representation
 *
 *  @return The connection mode of the string
 */
CMXWifiConnectionMode stringToConnectionMode(NSString* string);
