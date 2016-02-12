//
//  SLIndoorLocationEnums.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//
//

#ifndef SLIndoorLocation_SLIndoorLocationEnums_h
#define SLIndoorLocation_SLIndoorLocationEnums_h

/**
 Gives a status of the location estimate.
 */
typedef enum SLLocationStatusType : NSInteger SLLocationStatusType;
enum SLLocationStatusType : NSInteger {
    CONFIRMED,
    UNCONFIRMED,
    UNCONFIRMED_RADIO_DISTURBANCES
};

static NSString * const SLLocationStatusType_toString[] = {
    [CONFIRMED] = @"CONFIRMED",
    [UNCONFIRMED] = @"UNCONFIRMED",
    [UNCONFIRMED_RADIO_DISTURBANCES] = @"UNCONFIRMED_RADIO_DISTURBANCES"
};

#endif
