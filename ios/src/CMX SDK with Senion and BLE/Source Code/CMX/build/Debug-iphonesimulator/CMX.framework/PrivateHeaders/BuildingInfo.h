//
//  BuildingInfo.h
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SLIndoorLocation/SLIndoorLocationManager.h>
#import "FloorInfo.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SLIndoorLocation/SLCoordinate3D.h>
#import <SLIndoorLocation/SLPoint3D.h>

/**
 This class keeps information about the building the user is currently in and how the global
 properties of the building relate to the bitmap such as the long/lat location, orientation and scale.
 
 Note that the map information in this class is used only for showing the
 user location on a bitmap image of the building. This class is not used by the navigation filter.
 */
@interface BuildingInfo : NSObject {
}

/**
 Init function where the bitmap properties are stored in a JSON file (http://json.org).
 The structure and names of the JSON fields are the same as the class properties. 
 See below for an example of a JSON file.
 \verbatim
 {
	"name":"Building name",
	"bitmapFilename":"building.png",
	"bitmapOffset":{"x":472,"y":715},
	"bitmapLocation":{"latitude":47.5735,"longitude":-122.171049},
	"bitmapOrientation":-90,
	"pixelsPerMeter":2.877929732
 }
 \endverbatim
 */
- (id) initWithBitmapJsonFilename:(NSString*) bitmapJsonFilename;

/**
 This function converts a pixel position to longitude and latitude position. 
 */
- (SLCoordinate3D*) pixelPoint2LongLat:(SLPoint3D*)point;

/**
 Convert a longitude and latitude position to a pixel coordinate.
 */
- (SLPoint3D*) longLat2PixelPoint:(SLCoordinate3D*) location_;

/**
 Convert compass heading to heading relative the screen reference system.
 */
- (double) heading2PixelHeading:(double)heading andFloorNr:(NSInteger) floorNr_;

/**
 Get default floor number.
 */
- (NSInteger) getDefaultFloorNr;

/**
 Get the floorInfo of floor floorNr.
 */
- (FloorInfo*) getFloorInfo:(NSInteger)floorNr_;


/**
 The name of the building.
 */
@property(readonly, strong) NSMutableString* name;

/**
 The date of the data.
 */
@property(readonly, strong) NSMutableString* dataDate;

/**
 The list containing all floorInfo
 */
@property (strong) NSDictionary *floorInfoList;

/**
 The list containing all floorInfo
 */
@property (strong) NSMutableArray *floorNrArray;
 
@end
