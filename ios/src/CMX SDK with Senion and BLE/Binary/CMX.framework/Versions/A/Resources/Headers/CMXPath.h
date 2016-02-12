//
//  CMXPath.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Define a navigation path made of 2D points.
 */
@interface CMXPath : NSObject

/**
 *  Array of points (CMXPoint) representing the path.
 */
@property (nonatomic, strong, readonly) NSArray *points;

/**
 *  Init a path object from an array of points (CMXPoint).
 *
 *  @param points Array of points (CMXPoint)
 *
 *  @return Current instance.
 */
-(id)initWithPoints:(NSArray*)points;

@end
