//
//  CMXClientConfiguration.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXClientConfiguration.h"

static NSString* kDefaultVenueDetailsFilename = @"configuration";
static NSString* kDefaultVenueDetailsFileExtension = @"plist";

static NSString* kServerURLKey = @"Server URL";

@implementation CMXClientConfiguration


////////////////////////////////////////////////////////////////////////////////////////////////////
+(CMXClientConfiguration*) defaultConfiguration {
    NSString* path = [[NSBundle mainBundle] pathForResource:kDefaultVenueDetailsFilename ofType:kDefaultVenueDetailsFileExtension];
    return [CMXClientConfiguration configurationWithContentsOfFile:path];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+(CMXClientConfiguration*) configurationWithContentsOfFile:(NSString*)path {
    CMXClientConfiguration* config = nil;
    NSDictionary* data = [NSDictionary dictionaryWithContentsOfFile:path];
    if(data) {
        config = [[CMXClientConfiguration alloc] init];
        if([data objectForKey:kServerURLKey]) {
            config.serverURL = [NSURL URLWithString:[data objectForKey:kServerURLKey]];
        }
    }
    return config;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
    self = [super init];
    if (self) {
        self.serverURL = nil;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id) copy {
    CMXClientConfiguration *another = [[CMXClientConfiguration alloc] init];
    another.serverURL = [_serverURL copy];
    
    return another;
}

@end
