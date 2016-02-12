//
//  CMXPoiListViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMXSearchViewControllerDelegate;

@class CMXPoi;
@class CMXVenue;

/*!
 * @header CMXSearchViewController
 * This view controller is launched after the Main View Controller. It is meant to search names (poi) and
 * display the results in tabular form
 * @copyright Cisco Systems
 */

/*!
 *  @class CMXSearchViewController
 *  @abstract Controller that manages a search widget and displays result of the search in a table.
 */
@interface CMXSearchViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

/*!
 *  @property delegate Controller delegate.
 **/
@property (nonatomic, assign) id<CMXSearchViewControllerDelegate> delegate;

/*!
 *  @abstract Initialize the controller with given venue. Search will be done only for this venue.
 *
 *  @param venue Venue object.
 *
 *  @return Current instance
 */
-(id) initWithVenue:(CMXVenue*)venue;

@end



////////////////////////////////////////////////////////////////////////////////////////////////////

/*!
 *  @protocol CMXSearchViewControllerDelegate Delegate of search controller.
 */
@protocol CMXSearchViewControllerDelegate <NSObject>

@optional

/*!
 *  @abstract Method called when a poi has been selected.
 *
 *  @param controller Search controller.
 *  @param poi        Selected poi.
 */
-(void) searchViewController:(CMXSearchViewController*)controller didSelectPoi:(CMXPoi*)poi;

/*!
 *  @abstract Method called when accessory button of a poi has been tapped.
 *
 *  @param controller Search controller
 *  @param poi        Selected poi.
 */
-(void) searchViewController:(CMXSearchViewController*)controller accessoryButtonTappedForPoi:(CMXPoi*)poi;

@end
