//
//  CMXUnit.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Defines unit type.
 */
typedef NS_ENUM(NSUInteger, CMXUnit) {
    /**
     *  Feet unit type.
     */
    FEET,
};

/**
 *  Convert unit value to string representation.
 *
 *  @param unit a unit type
 *
 *  @return The string representation of the unit type
 */
NSString* unitToString(CMXUnit unit);

/**
 *  Convert string representation to unit.
 *
 *  @param string a string representation
 *
 *  @return The unit type of the string
 */
CMXUnit stringToUnit(NSString* string);