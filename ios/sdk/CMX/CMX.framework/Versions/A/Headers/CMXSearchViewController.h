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

/**
 *  Controller that manages a search widget and displays result of the search in a table.
 */
@interface CMXSearchViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

/**
 *  Controller delegate.
 **/
@property (nonatomic, assign) id<CMXSearchViewControllerDelegate> delegate;

/**
 *  Initialize the controller with given venue. Search will be done only for this venue.
 *
 *  @param venue Venue object.
 *
 *  @return Current instance
 */
-(id) initWithVenue:(CMXVenue*)venue;

@end



////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  Delegate of search controller.
 */
@protocol CMXSearchViewControllerDelegate <NSObject>

@optional

/**
 *  Method called when a poi has been selected.
 *
 *  @param controller Search controller.
 *  @param poi        Selected poi.
 */
-(void) searchViewController:(CMXSearchViewController*)controller didSelectPoi:(CMXPoi*)poi;

/**
 *  Method call when accessory button of a poi has been tapped.
 *
 *  @param controller Search controller
 *  @param poi        Selected poi.
 */
-(void) searchViewController:(CMXSearchViewController*)controller accessoryButtonTappedForPoi:(CMXPoi*)poi;

@end
