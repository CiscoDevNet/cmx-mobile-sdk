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

/*!
 * @header CMXMenuViewController
 * This view controller is launched from the Main View Controller. It is meant to control the menu panel on the left.
 * @copyright Cisco Systems
 */


/*!
 *  @class CMXMenuViewController
 *  @abstract Controller used to display menu (left panel)
 */
@interface CMXMenuViewController : UITableViewController

/*!
 *  @property delegate Menu delegate
 **/
@property (nonatomic,assign) id<CMXMenuViewControllerDelegate> delegate;

/*!
 *  @abstract Initialize the controller with data.
 *
 *  @param venues          Array of venues
 *  @param floorsByVenueId Dictionary of arrays of floors (key = venue id).
 *  @param userLocation    current user location if known, nil otherwise.
 */
-(void) setupWithVenues:(NSArray*)venues floors:(NSDictionary*)floorsByVenueId userLocation:(CMXClientLocation*)userLocation;

/*!
 *  @abstract Update menu items with the new current floor.
 *
 *  @param floor Current floor where user is located.
 */
-(void) updateMenuItemsWithNewCurrentFloor:(CMXFloor*)floor;


@end

/*!
 *  @protocol CMXMenuViewControllerDelegate Delegate of menu view controller.
 */
@protocol CMXMenuViewControllerDelegate <NSObject>

@optional

/*!
 *  @abstract Method called when a floor item has been selected in the menu.
 *
 *  @param controller Menu controller.
 *  @param floorId    Id of the selected floor.
 *  @param venueId    Venue's id of the floor.
 */
-(void) menuViewController:(CMXMenuViewController*)controller didSelectFloorMenuItem:(NSString*)floorId ofVenue:(NSString*)venueId;

/*!
 *  @abstract Method called when settings item has been selected in the menu.
 *
 *  @param controller Menu controller.
 */
-(void) menuViewControllerDidSelectSettingsMenuItem:(CMXMenuViewController*)controller;

/*!
 *  @abstract Method called when user location item has been selected in the menu.
 *
 *  @param controller Menu controller.
 */
-(void) menuViewControllerDidSelectUserLocationMenuItem:(CMXMenuViewController*)controller;

@end
