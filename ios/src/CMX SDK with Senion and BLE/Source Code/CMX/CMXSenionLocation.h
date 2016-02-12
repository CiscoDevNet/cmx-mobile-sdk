//
//  CMXSenionLocation.h
//  CMX
//
//  Created by Abhishek Bhattacharyya on 4/25/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SLIndoorLocation/SLPoint3D.h>

@interface CMXSenionLocation : SLPoint3D

//this is in epoch time in milliseconds. The part before the decimals (10 digits is in seconds)
@property (nonatomic) double locationUpdateTime;

//the uncertainty radius is in meters
@property (nonatomic) double uncertaintyRadius;


- (id) initSenionLocationWithLocation: (SLPoint3D*) bleLocation andTimeStamp: (double) locationUpdateTime andUncertaintyRadius: (double) uncertaintyRadius;

@end
