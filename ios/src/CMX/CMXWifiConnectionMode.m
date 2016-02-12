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
        case NONE:
            result = @"none";
            break;
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
    if([string isEqualToString:@"auto"] || [string isEqualToString:@"AUTO"]) {
        return AUTO;
    }
    else if([string isEqualToString:@"manual"] || [string isEqualToString:@"MANUAL"]) {
        return MANUAL;
    }
    else if([string isEqualToString:@"prompt"] || [string isEqualToString:@"PROMPT"]) {
        return PROMPT;
        
    }else if([string isEqualToString:@"none"] || [string isEqualToString:@"NONE"]) {
        return NONE;
    }
    [NSException raise:NSGenericException format:@"Unexpected connection mode (%@).", string];
    return 0;
}
