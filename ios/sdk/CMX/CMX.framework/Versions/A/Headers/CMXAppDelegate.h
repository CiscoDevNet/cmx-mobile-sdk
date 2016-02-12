//
//  CMXAppDelegate.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Default application delegate. 
This implementation manages :

* remote notifications
* create launch controller and load data

*/
@interface CMXAppDelegate : UIResponder<UIApplicationDelegate>

/**
 *  Window used by the app.
 */
@property (strong, nonatomic) UIWindow *window;

@end
