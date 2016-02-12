//
//  CMXLoadingView.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Loading view.
 */
@interface CMXLoadingView : UIView

/**
 @brief Creates and adds a loading view.
 @param superView view that will be covered by the loading view
 @param title title of the loading view
 @return An initialized view or nil if the object couldn't be created.
 */
+ (id)loadingViewInView:(UIView*)superView withTitle:(NSString*)title;

/**
 @brief Remove the loading view from the superview, with animation.
 */
- (void)removeView;


@end