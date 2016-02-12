//
//  CMXUnit.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXUnit.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
NSString* unitToString(CMXUnit unit) {
    NSString *result = nil;
    
    switch(unit) {
        case FEET:
            result = @"FEET";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected Unit type."];
    }
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
CMXUnit stringToUnit(NSString* string) {
    if([string isEqualToString:@"FEET"]) {
        return FEET;
    }
    [NSException raise:NSGenericException format:@"Unexpected Unit type (%@).", string];
    return 0;
}