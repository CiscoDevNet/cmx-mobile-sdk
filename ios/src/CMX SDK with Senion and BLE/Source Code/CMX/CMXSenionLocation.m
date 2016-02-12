//
//  CMXSenionLocation.m
//  CMX
//
//  Created by Abhishek Bhattacharyya on 4/25/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import "CMXSenionLocation.h"
#import "CMXDebug.h"

@implementation CMXSenionLocation

- (id) initSenionLocationWithLocation: (SLPoint3D*) bleLocation andTimeStamp: (double) locationUpdateTime andUncertaintyRadius: (double) uncertaintyRadius{
    
    self = [super initWithX:bleLocation.x andY:bleLocation.y andFloorNr:bleLocation.floorNr];
    
    self.locationUpdateTime = locationUpdateTime;
    self.uncertaintyRadius = uncertaintyRadius;
    
    return self;
}

@end
