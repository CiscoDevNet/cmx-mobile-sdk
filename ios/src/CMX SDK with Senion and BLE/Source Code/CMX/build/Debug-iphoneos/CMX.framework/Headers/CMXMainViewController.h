//
//  CMXMainViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "CMXMenuViewController.h"
#import "CMXSearchViewController.h"
#import "CMXFloorViewController.h"
#import "CMXPoiViewController.h"

/*!
 * @header CMXMainViewController
 * This is the first view controller which gets launched.It calls the menu view controllers, the content views including the
 * LaunchViewController to load user data.
 * @copyright Cisco Systems
 */

@class CMXClientLocation, CMXVenue, CMXFloor;

/*!
 * @class CMXMainViewController
 * @abstract Main controller. It holds data (venues, floors, ...), displays the map and manages left (menu) & right (search) panels.
 */
@interface CMXMainViewController : JASidePanelController<CMXMenuViewControllerDelegate, CMXSearchViewControllerDelegate, CMXPoiViewControllerDelegate, CMXFloorViewControllerDelegate>

/*!
 *  @property currentVenueId Current venue id or nil if none.
 */
@property (nonatomic, strong, readonly) NSString* currentVenueId;

/*!
 *  @property currentFloorId Current floor id or nil if none.
 */
@property (nonatomic, strong, readonly) NSString* currentFloorId;

/*!
 *  @abstract Initialize this controller with data.
 *
 *  @param venues          Array of venues.
 *  @param floorsByVenueId Dictionary of arrays of floors (key = venue id).
 *  @param userLocation    current user location if known, nil otherwise.
 *
 *  @return Current controller instance.
 */
-(id)initWithVenues:(NSArray*)venues
    floorsByVenueId:(NSDictionary *)floorsByVenueId
       userLocation:(CMXClientLocation *)userLocation;

/*!
 *  @abstract Returns the CMXVenue object for the given venue id.
 *
 *  @param venueId Id of the venue
 *
 *  @return A venue object if matching, nil otherwise.
 */
-(CMXVenue*) venueWithId:(NSString*)venueId;

/*!
 *  @abstract Returns the CMXFloor object for the given floor & venue ids.
 *
 *  @param floorId Id of the floor
 *  @param venueId Id of the venue
 *
 *  @return A floor object if matching, nil otherwise.
 */
-(CMXFloor*) floorWithId:(NSString*)floorId ofVenue:(NSString*)venueId;


@end
