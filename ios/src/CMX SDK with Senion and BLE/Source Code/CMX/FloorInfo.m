//
//  FloorInfo.m
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import "FloorInfo.h"


@implementation FloorInfo

double const footInMeter = 0.3048;

@synthesize floorName, floorId, bitmapLocation, bitmapOffset, pixelsPerMeter, bitmapOrientation, bitmapFilename,xMaxPixels,yMaxPixels;

- (id) initWithName:(NSString*) name_
         andFloorId:(NSInteger) floorId_
  andBitmapLocation:(SLCoordinate2D*) bitmapLocation_
    andBitmapOffset:(CGPoint) bitmapOffset_
andBitmapOrientation:(double) bitmapOrientation_
  andBitmapFilename:(NSString*) bitmapFilename_
  andPixelsPerMeter:(double) pixelsPerMeter_
      andxMaxPixels:(double) xMaxPixels_
      andyMaxPixels:(double) yMaxPixels_
{
	floorName = [[NSMutableString alloc] initWithString:name_];
    floorId = floorId_;
	bitmapLocation = bitmapLocation_;
	bitmapOffset = bitmapOffset_;
	bitmapOrientation = bitmapOrientation_;
	bitmapFilename = [[NSMutableString alloc] initWithString:bitmapFilename_];
	pixelsPerMeter = pixelsPerMeter_;
    xMaxPixels = xMaxPixels_;
    yMaxPixels = yMaxPixels_;
	return self;
}

- (id) initWithName:(NSString*) name_
         andFloorId:(NSInteger) floorId_
  andBitmapLocation:(SLCoordinate2D*) bitmapLocation_
    andBitmapOffset:(CGPoint) bitmapOffset_
andBitmapOrientation:(double) bitmapOrientation_
  andBitmapFilename:(NSString*) bitmapFilename_
  andPixelsPerFoot:(double) pixelsPerFoot_
      andxMaxPixels:(double) xMaxPixels_
      andyMaxPixels:(double) yMaxPixels_
{
	return [self initWithName:name_ andFloorId:floorId_ andBitmapLocation:bitmapLocation_ andBitmapOffset:bitmapOffset_ andBitmapOrientation:bitmapOrientation_ andBitmapFilename:bitmapFilename_ andPixelsPerMeter:(pixelsPerFoot_ * footInMeter) andxMaxPixels:xMaxPixels_ andyMaxPixels:yMaxPixels_];
}

@end
