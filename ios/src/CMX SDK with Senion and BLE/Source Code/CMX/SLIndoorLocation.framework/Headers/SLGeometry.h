//
//  SLGeometry.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLGeometryId.h"

/**
 @protocol SLGeometry
 Protocol used by all areas that should be monitored in geofencing.
 */
@protocol SLGeometry <NSObject>
/**
 Gets the id for this area.
 */
- (SLGeometryId*) getGeometryId;
@end
