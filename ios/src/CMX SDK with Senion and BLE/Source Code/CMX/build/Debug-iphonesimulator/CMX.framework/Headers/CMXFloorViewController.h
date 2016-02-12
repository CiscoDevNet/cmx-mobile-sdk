//
//  CMXFloorViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMXMapView.h"

@protocol CMXFloorViewControllerDelegate;

@class CMXFloor;
@class CMXVenue;
@class CMXPoi;
@class CMXMapView;
@class CMXBannerViewController;

/*!
 * @header CMXFloorViewController
 * This view controller is launched from the Main View Controller. It is meant to display
 * the floor map and banners 
 * @copyright Cisco Systems
 */


/*!
 * @class CMXFloorViewController
 * @abstract Controller that displays floor map
 */
@interface CMXFloorViewController : UIViewController<CMXMapViewDelegate>

/*!
 * @property mapView 
 *              View used to display map.
 */
@property (nonatomic, strong, readonly) CMXMapView* mapView;

/*!
 * @property bannerViewController
 *                  View controller for the banner displayed in mapview.
 */
@property (nonatomic, strong, readonly) CMXBannerViewController *bannerViewController;

/*!
 * @property delegate
 *              Floor controller delegate.
 */
@property (nonatomic, assign) id<CMXFloorViewControllerDelegate> delegate;

/*!
*  @abstract Initialize the controller with an object containing floor informations and an object containing venue informations.
*
*  @param floor Object containing floor informations.
*  @param venue Object containing venue informations.
*
*  @return Current object instance.
*/
- (id) initWithFloor:(CMXFloor *)floor ofVenue:(CMXVenue*)venue;


/*!
 *  @abstract Update the controller and the map with an object containing floor informations and an object containing venue informations.
 *
 *  @param floor Object containing floor informations.
 *  @param venue Object containing venue informations.
 */
- (void) updateControllerWithFloor:(CMXFloor *)floor ofVenue:(CMXVenue*)venue;

/*!
 *  @abstract Set the target destination. It will display on map the path from the current client location to the target destionation.
 *
 *  @param poiId Poi's id of the destination.
 */
-(void) setTargetDestination:(NSString*)poiId;

/*!
 *  @abstract Update client location on map and path to target destination if set.
 *
 *  @param location New client location.
 */
-(void) setClientLocation:(CMXClientLocation*)location;

/*!
 *  @abstract Returns a poi given an id, or nil if not available
 *
 *  @param poiId Id of the poi.
 *
 *  @return A poi object if found, nil otherwise.
 */
-(CMXPoi*) poiWithId:(NSString*)poiId;

/*!
 *  @abstract Returns the image of the corresponding poi id.
 *
 *  @param poiId Id of the poi.
 *
 *  @return An image object if found, nil otherwise.
 */
-(UIImage*) imageOfPoi:(NSString*)poiId;

@end


/*!
 * @protocol CMXFloorViewControllerDelegate
 *              CMXFloorViewController delegate protocol
 */
@protocol CMXFloorViewControllerDelegate<NSObject>

@optional

/*!
 *  @abstract Method called when client has selected a poi on map.
 *
 *  @param controller Floor view controller.
 *  @param poi        Id of the selected poi.
 */
-(void) floorViewController:(CMXFloorViewController*)controller didSelectPoi:(NSString*)poi;

@end

