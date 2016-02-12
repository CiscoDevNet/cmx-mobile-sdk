//
//  CMXMenuViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMXClientLocation;
@class CMXFloor;
@protocol CMXMenuViewControllerDelegate;


/**
 *  Controller used to display menu (left panel)
 */
@interface CMXMenuViewController : UITableViewController

/**
 *  Menu delegate
 **/
@property (nonatomic,assign) id<CMXMenuViewControllerDelegate> delegate;

/**
 *  Initialize the controller with data.
 *
 *  @param venues          Array of venues
 *  @param floorsByVenueId Dictionary of arrays of floors (key = venue id).
 *  @param userLocation    current user location if known, nil otherwise.
 */
-(void) setupWithVenues:(NSArray*)venues floors:(NSDictionary*)floorsByVenueId userLocation:(CMXClientLocation*)userLocation;

/**
 *  Update menu items with the new current floor.
 *
 *  @param floor Current floor where user is located.
 */
-(void) updateMenuItemsWithNewCurrentFloor:(CMXFloor*)floor;


@end

/**
 *  Delegate of menu view controller.
 */
@protocol CMXMenuViewControllerDelegate <NSObject>

@optional

/**
 *  Method called when a floor item has been selected in the menu.
 *
 *  @param controller Menu controller.
 *  @param floorId    Id of the selected floor.
 *  @param venueId    Venue's id of the floor.
 */
-(void) menuViewController:(CMXMenuViewController*)controller didSelectFloorMenuItem:(NSString*)floorId ofVenue:(NSString*)venueId;

/**
 *  Method called when settings item has been selected in the menu.
 *
 *  @param controller Menu controller.
 */
-(void) menuViewControllerDidSelectSettingsMenuItem:(CMXMenuViewController*)controller;

/**
 *  Method called when user location item has been selected in the menu.
 *
 *  @param controller Menu controller.
 */
-(void) menuViewControllerDidSelectUserLocationMenuItem:(CMXMenuViewController*)controller;

@end
