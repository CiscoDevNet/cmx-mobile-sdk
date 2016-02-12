//
//  FloorInfo.h
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SLIndoorLocation/SLCoordinate2D.h>
#import <SLIndoorLocation/SLCoordinate3D.h>


@interface FloorInfo : NSObject {
}

- (id) initWithName:(NSString*) name_
         andFloorId:(NSInteger) floorId_
  andBitmapLocation:(SLCoordinate2D*) bitmapLocation_
    andBitmapOffset:(CGPoint) bitmapOffset_
andBitmapOrientation:(double) bitmapOrientation_
  andBitmapFilename:(NSString*) bitmapFilename_
  andPixelsPerMeter:(double) pixelsPerMeter_;

- (id) initWithName:(NSString*) name_
         andFloorId:(NSInteger) floorId_
  andBitmapLocation:(SLCoordinate2D*) bitmapLocation_
    andBitmapOffset:(CGPoint) bitmapOffset_
andBitmapOrientation:(double) bitmapOrientation_
  andBitmapFilename:(NSString*) bitmapFilename_
   andPixelsPerFoot:(double) pixelsPerFoot_;
 
/**
 Constant for converting feet to meters and vice versa.
 */
extern double const footInMeter; 

/**
 The name of the floor.
 */
@property(readonly, strong) NSMutableString* floorName;

/**
 The id of the floor.
 */
@property(readonly) NSInteger floorId;

/**
 The file name of the bitmap image file. Preferably a PNG file, but not necessary.
 */
@property(readonly, strong) NSMutableString* bitmapFilename;

/**
 The location of the bitmap expressed in latitude and longitude [deg].
 */
@property(readonly, strong) SLCoordinate2D *bitmapLocation;

/**
 The offset of the reference point \c bitmapLocationbitmap relative the bitmap origin (upper left corner). 
 
 \c bitmapOffset is the location of the reference point \c bitmapLocation
 in the bitmap expressed in pixels relative the upper left corner of the bitmap 
 with x-axis pointing to the right and 
 the y-axis pointing downwards, i.e., the standard computer vision definition.
 For example, if \c bitmapLocation represent the location of the upper left corner
 of the bitmap the offset is (x,y) = (0,0).
 */
@property(readonly) CGPoint bitmapOffset;

/**
 The orientation of the bitmap. The orientation is defined as the 
 angle between true North in the bitmap and the up-direction of the bitmap
 (i.e., the minus y-axis) in the clock-wise direction. 
 For example, if North is pointing to the left in the bitmap, then
 the orientation is 90 degrees.
 */
@property(readonly) double bitmapOrientation;

/**
 The scale of the bitmap. The number of pixels in the bitmap corresponding to one meter.
 */
@property(readonly) double pixelsPerMeter; 


@end
