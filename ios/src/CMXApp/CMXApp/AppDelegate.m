//
//  AppDelegate.m
//  CMXApp
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "AppDelegate.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

#pragma mark UIApplication delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerDefaultsFromSettingsBundle];
    
    // Configure CMX client with app settings
    CMXClientConfiguration* configuration = [self configurationFromSettings];
    if([AppDelegate checkConfiguration:configuration]) {
        [CMXClient instance].configuration = configuration;
    }
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [super applicationDidBecomeActive:application];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    CMXClientConfiguration* newConfig = [self configurationFromSettings];
    CMXClientConfiguration* currentConfig = [CMXClient instance].configuration;
    
    // Check if configuration has changed and is valid
    if([AppDelegate checkConfiguration:newConfig] && ![[newConfig.serverURL absoluteString] isEqualToString:[currentConfig.serverURL absoluteString]]) {

        // If so, we reload data with new configuration
        [CMXClient instance].configuration = newConfig;
        
        self.window.rootViewController = [[CMXLaunchViewController alloc] init];
        [self.window makeKeyAndVisible];
    }
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Create client configuration from app settings
-(CMXClientConfiguration*) configurationFromSettings {
    CMXClientConfiguration *config = [[CMXClientConfiguration alloc] init];
    config.serverURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"serverUrl"]];

    return config;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Check if the given configuration is valid
+(BOOL) checkConfiguration:(CMXClientConfiguration*)configuration {
    BOOL res = configuration.serverURL != nil;
    if(!res) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CMX Warning Alert Title", @"") message:NSLocalizedString(@"CMX Invalid Configuration", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CMX OK Button", @"") otherButtonTitles:nil];
        [alertView show];
    }
    return res;
}

@end
