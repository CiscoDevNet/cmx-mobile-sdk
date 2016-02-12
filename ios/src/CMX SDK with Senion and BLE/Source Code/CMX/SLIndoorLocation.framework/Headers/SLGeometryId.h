//
//  SLGeometryId.h
//  SLIndoorLocation
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @interface SLGeometryId
 This class is used to identify a geometry that should be monitored. 
 Make sure that each geometry has a unique id.
 */
@interface SLGeometryId : NSObject

/**
 Constructor.
 @param geometryId_ Unique string that identifies your geometry.
 */
- (id) initWithGeometryId:(NSString*)geometryId_;

@property(strong) NSString *geometryId;

@end
