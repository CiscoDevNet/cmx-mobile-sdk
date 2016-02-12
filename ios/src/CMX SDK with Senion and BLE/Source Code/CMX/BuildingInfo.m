//
//  BuildingInfo.m
//
//  Copyright (c) 2010-2014, SenionLab AB. All rights reserved.
//

#import "BuildingInfo.h"
#import "FloorInfo.h"
#import <UIKit/UIKit.h>
#import "CMXDebug.h"

@implementation BuildingInfo


@synthesize name, dataDate, floorInfoList, floorNrArray;

- (id) initWithBitmapJsonFilename:(NSString*) bitmapJsonFilename
{
     
	NSString *filePath = [[NSBundle mainBundle] pathForResource:bitmapJsonFilename ofType:@"json"];
	NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
	if (!content) {
		NSLog(@"BuildingInfo: Error in input argument <bitmapJsonFilename>, file %@ does not exist!", bitmapJsonFilename);
		return nil;
	}

    NSError *error = nil;
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:&error];
    
	
	name = [[NSMutableString alloc] initWithString:[json objectForKey:@"name"]];
	dataDate = [[NSMutableString alloc] initWithString:[json objectForKey:@"dataDate"]];
    NSArray *floorsArray = [json objectForKey:@"floors"];

    NSUInteger nFloors = floorsArray.count;
  //  NSLog(@"nFloors = %d \n", nFloors);
    
    
	NSMutableArray *floorInfoArray = [[NSMutableArray alloc] initWithCapacity:nFloors];
    floorNrArray = [[NSMutableArray alloc] initWithCapacity:nFloors];

    CGPoint bitmapOffset;
    NSString* bitmapFilename;
    double bitmapOrientation, pixelsPerMeter,xMaxPixels,yMaxPixels;
    NSInteger floorNr;
    NSString* floorName;
    
    
    for(NSDictionary *floor in floorsArray) {
        NSDictionary *bitmapLocationObj = [floor objectForKey:@"bitmapLocation"];
        double latitude = [[bitmapLocationObj objectForKey:@"latitude"] doubleValue];
        double longitude = [[bitmapLocationObj objectForKey:@"longitude"] doubleValue];
        SLCoordinate2D *bitmapLocation = [[SLCoordinate2D alloc] initWithLatitude:latitude andLongitude:longitude];
        NSDictionary *bitmapOffsetObj = [floor objectForKey:@"bitmapOffset"];
        bitmapOffset.x = [[bitmapOffsetObj objectForKey:@"x"] doubleValue];
        bitmapOffset.y = [[bitmapOffsetObj objectForKey:@"y"] doubleValue];
        bitmapOrientation = [[floor objectForKey:@"bitmapOrientation"] doubleValue];
        bitmapFilename = [[NSMutableString alloc] initWithString:[floor objectForKey:@"bitmapFilename"]];
        pixelsPerMeter = [[floor objectForKey:@"pixelsPerMeter"] doubleValue];
        xMaxPixels = [[floor objectForKey:@"xMaxPixels"] doubleValue];
        yMaxPixels = [[floor objectForKey:@"yMaxPixels"] doubleValue];
        floorName = [[NSMutableString alloc] initWithString:[floor objectForKey:@"floorName"]];
        floorNr = [[floor objectForKey:@"floorNr"] integerValue];

        FloorInfo *floorInfo = [[FloorInfo alloc]     initWithName:floorName
                                                    andFloorId:floorNr
                                             andBitmapLocation:bitmapLocation
                                               andBitmapOffset:bitmapOffset
                                          andBitmapOrientation:bitmapOrientation
                                             andBitmapFilename:bitmapFilename
                                             andPixelsPerMeter:pixelsPerMeter
                                                 andxMaxPixels:xMaxPixels
                                                 andyMaxPixels:yMaxPixels];
        
        [floorInfoArray addObject:floorInfo];
        NSNumber *num = [[NSNumber alloc] initWithInteger:floorNr];
        [floorNrArray addObject:num];
	}
    
    floorInfoList = [[NSDictionary alloc] initWithObjects:floorInfoArray forKeys:floorNrArray];
	
	return self;
}

- (double) heading2PixelHeading:(double) heading_ andFloorNr:(NSInteger) floorNr_
{
    FloorInfo* f = [self getFloorInfo:floorNr_];
	return  - f.bitmapOrientation + heading_;
}


- (FloorInfo*) getFloorInfo:(NSInteger)floorNr_ {
    NSNumber *num = [[NSNumber alloc] initWithInteger:floorNr_];
    FloorInfo* f = [floorInfoList objectForKey:num];
    return f;
}

- (SLCoordinate3D*) pixelPoint2LongLat:(SLPoint3D*)point
{
    FloorInfo* f = [self getFloorInfo:point.floorNr];

	// This function makes a local approximation and should not be used over long distances
	const double a = 6378137; // Equatorial earth radius
	const double b = 6356752.314245; // Polar earth radius
	const double r = 0.5*(a+b); // Use average earth radius in this function
	// Transform to a coordinate system in upper left corner of image
	double deltaX = (f.bitmapOffset.y-point.y)/f.pixelsPerMeter;
	double deltaY = (f.bitmapOffset.x-point.x)/f.pixelsPerMeter;
	// Rotate to NW-system
	double deltaN = cos(f.bitmapOrientation*M_PI/180.0)*deltaX + sin(f.bitmapOrientation*M_PI/180.0)*deltaY;
	double deltaW = -sin(f.bitmapOrientation*M_PI/180.0)*deltaX + cos(f.bitmapOrientation*M_PI/180.0)*deltaY;
	
	double latitude = f.bitmapLocation.latitude + 180.0/M_PI*deltaN/r;
	double longitude = f.bitmapLocation.longitude - 180.0/M_PI*deltaW/(r*cos(f.bitmapLocation.latitude*M_PI/180.0));
	return [[SLCoordinate3D alloc] initWithLatitude:latitude andLongitude:longitude andFloorNr:point.floorNr];
}

- (SLPoint3D*) longLat2PixelPoint:(SLCoordinate3D*) location_
{
    FloorInfo* f = [self getFloorInfo:location_.floorNr];

	// This function makes a local approximation and should not be used over long distances
	const double a = 6378137; // Equatorial earth radius
	const double b = 6356752.314245; // Polar earth radius
	const double r = 0.5*(a+b); // Use average earth radius in this function
	
	double deltaN =  (location_.latitude  - f.bitmapLocation.latitude) * M_PI/180*r;
	double deltaW = -(location_.longitude - f.bitmapLocation.longitude)* M_PI/180*r*cos(f.bitmapLocation.latitude*M_PI/180.0);
	double deltaX = cos(f.bitmapOrientation*M_PI/180.0)*deltaN - sin(f.bitmapOrientation*M_PI/180.0)*deltaW;
	double deltaY = sin(f.bitmapOrientation*M_PI/180.0)*deltaN + cos(f.bitmapOrientation*M_PI/180.0)*deltaW;
    
    
    //this is for meters
    //double x = -deltaY + f.bitmapOffset.x / f.pixelsPerMeter;
    //double y = -deltaX + f.bitmapOffset.y/ f.pixelsPerMeter;
    
    //this is in pixels
    double x = (-deltaY*f.pixelsPerMeter + f.bitmapOffset.x) ;
    double y = (-deltaX*f.pixelsPerMeter + f.bitmapOffset.y) ;
    CMXLog(@"x in pixels is %f",x);
    CMXLog(@"y in pixels is %f",y);
    
    //this is a ratio
    x = x / f.xMaxPixels;
    y = y / f.yMaxPixels;
    CMXLog(@"x in ratio is %f",x);
    CMXLog(@"y in ratio is %f",y);
    
	return [[SLPoint3D alloc] initWithX:x andY:y andFloorNr:location_.floorNr];
}

- (NSInteger) getDefaultFloorNr
{
    return [[floorNrArray objectAtIndex:0] integerValue];
}


@end
