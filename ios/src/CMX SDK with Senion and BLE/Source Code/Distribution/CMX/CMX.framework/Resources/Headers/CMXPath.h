//
//  CMXPath.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @header CMXPath 
 * Defines the path as an array of points.
 * @copyright Cisco Systems
 */


/*!
 * @class CMXPath
 * @abstract Define a navigation path made of 2D points.
 */
@interface CMXPath : NSObject

/*!
 *  @property points Array of points (CMXPoint) representing the path.
 */
@property (nonatomic, strong, readonly) NSArray *points;

/*!
 *  @abstract Init a path object from an array of points (CMXPoint).
 *
 *  @param points Array of points (CMXPoint)
 *
 *  @return Current instance.
 */
-(id)initWithPoints:(NSArray*)points;

@end
