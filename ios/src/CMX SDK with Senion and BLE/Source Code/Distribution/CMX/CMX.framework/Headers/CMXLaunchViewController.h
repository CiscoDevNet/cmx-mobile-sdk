//
//  LaunchViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>


/*!
 * @header CMXLaunchViewController
 * This view controller is launched after the Main View Controller. It is meant to load 
 * data, do client registration, get user location etc.
 * @copyright Cisco Systems
 */


@class CMXClientLocation;

/*!
 * @class CMXLaunchViewController
 * @abstract Controller that loads data at launch after MainViewController.
 */
@interface CMXLaunchViewController : UIViewController


/*!
 * @abstract Block called when all data are loaded.
 * @discussion The block takes 3 arguments : the list of venues, the list of floors ordered by venue id, the user location or nil if not available
 */
@property (nonatomic, copy) void(^onDataLoaded)(NSArray *venues, NSDictionary *floorsByVenueId, CMXClientLocation *userLocation);

@end
