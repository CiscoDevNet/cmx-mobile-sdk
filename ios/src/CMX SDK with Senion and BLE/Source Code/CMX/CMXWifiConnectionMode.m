//
//  CMXWifiConnectionMode.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXWifiConnectionMode.h"


NSString* connectionModeToString(CMXWifiConnectionMode mode) {
    NSString *result = nil;
    
    switch(mode) {
        case AUTO:
            result = @"auto";
            break;
        case MANUAL:
            result = @"manual";
            break;
        case PROMPT:
            result = @"prompt";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected connection mode."];
    }
    
    return result;
}

CMXWifiConnectionMode stringToConnectionMode(NSString* string) {
    if([string isEqualToString:@"auto"]) {
        return AUTO;
    }
    else if([string isEqualToString:@"manual"]) {
        return MANUAL;
    }
    else if([string isEqualToString:@"prompt"]) {
        return PROMPT;
    }
    [NSException raise:NSGenericException format:@"Unexpected connection mode (%@).", string];
    return 0;
}