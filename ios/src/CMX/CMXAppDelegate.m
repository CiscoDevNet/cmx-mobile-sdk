//
//  CMXAppDelegate.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXAppDelegate.h"
#import "CMXClient.h"
#import "CMXLaunchViewController.h"
#import "CMXMainViewController.h"
#import "CMXNotifications.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation CMXAppDelegate

#pragma mark UIApplation deletage
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CMXLaunchViewController* launcherController = [[CMXLaunchViewController alloc] init];
    
    __weak CMXAppDelegate *weakSelf = self;
    launcherController.onDataLoaded = ^(NSArray *venues, NSDictionary *floorsByVenueId, CMXClientLocation *userLocation) {
        
        CMXMainViewController* slidingViewController = [[CMXMainViewController alloc] initWithVenues:venues floorsByVenueId:floorsByVenueId userLocation:userLocation];
        weakSelf.window.rootViewController = slidingViewController;
        [weakSelf.window makeKeyAndVisible];
    };
    
    self.window.rootViewController = launcherController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceToken, CMXRemoteNotificationsDeviceTokenKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CMXRemoteNotificationsDidRegisterNotification object:nil userInfo:userInfo];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, CMXRemoteNotificationsErrorKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CMXRemoteNotificationsDidFailToRegisterNotification object:nil userInfo:userInfo];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Fire the handler
    [[CMXClient instance] handleNotification:userInfo applicationState:application.applicationState];
}

// FBSample logic
// In the login workflow, the Facebook native application, or Safari will transition back to
// this applicaiton via a url following the scheme fb[app id]://; the call to handleOpenURL
// below captures the token, in the case of success, on behalf of the FBSession object
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if([self hasFBAppId]) {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication];
    }
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if([self hasFBAppId]) {
        [FBAppEvents activateApp];
        [FBAppCall handleDidBecomeActive];
    }
}

// FBSample logic
// It is important to close any FBSession object that is no longer useful
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillTerminate:(UIApplication *)application {
    if([self hasFBAppId]) {
        // Close the session token before quitting
        [FBSession.activeSession close];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) hasFBAppId {
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"FacebookAppID"] != nil;
}



@end
