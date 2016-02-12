//
//  CMXPath.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXPath.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXPath()

@property (nonatomic, strong) NSArray *points;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXPath

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithPoints:(NSArray*)points_ {
    if(self = [super init]) {
        self.points = points_;
    }
    return self;
}

@end
