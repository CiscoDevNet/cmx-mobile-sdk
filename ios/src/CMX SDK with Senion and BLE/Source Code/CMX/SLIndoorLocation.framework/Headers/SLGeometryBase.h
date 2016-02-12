//
//  SLGeometryBase.h
//  SLIndoorLocation
//
//

#import <Foundation/Foundation.h>

@interface SLGeometryBase : NSObject

- (bool) isInsideReported;
- (void) didReportInside;
- (bool) isOutsideReported;
- (void) didReportOutside;

@end
