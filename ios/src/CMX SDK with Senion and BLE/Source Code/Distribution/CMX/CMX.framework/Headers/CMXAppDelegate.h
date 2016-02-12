//
//  CMXAppDelegate.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @header CMXAppDelegate
 * The main delegate for the CMX Application.This implementation manages : remote notifications, creating and launching the
 * main view controller and loading  data through the launch view controller
 * @copyright Cisco Systems
 */

/*!
 * @class CMXAppDelegate
 * @abstract Default application delegate.
 * @discussion This implementation manages : remote notifications, creating and launching the main view controller and loading
 *  data through the launch view controller
*/

@interface CMXAppDelegate : UIResponder<UIApplicationDelegate>

/*!
 * @property window
 *              Window used by the app.
 */
@property (strong, nonatomic) UIWindow *window;

@end
