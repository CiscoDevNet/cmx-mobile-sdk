//
//  LaunchViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMXClientLocation;

/**
 *  Controller that loads data at launch.
 */
@interface CMXLaunchViewController : UIViewController

/** Block called when all data are loaded. 
The block takes 3 arguments :

 - the list of venues,
 - the list of floors ordered by venue id
 - the user location or nil if not available
 */
@property (nonatomic, copy) void(^onDataLoaded)(NSArray *venues, NSDictionary *floorsByVenueId, CMXClientLocation *userLocation);

@end
