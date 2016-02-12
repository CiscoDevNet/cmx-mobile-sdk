//
//  CMXUnit.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @abstract Defines unit type.
 */
typedef NS_ENUM(NSUInteger, CMXUnit) {
    /**
     *  Feet unit type.
     */
    FEET,
};

/*!
 *  @abstract Convert unit value to string representation.
 *
 *  @param unit a unit type
 *
 *  @return The string representation of the unit type
 */
NSString* unitToString(CMXUnit unit);

/*!
 *  @abstract Convert string representation to unit.
 *
 *  @param string a string representation
 *
 *  @return The unit type of the string
 */
CMXUnit stringToUnit(NSString* string);