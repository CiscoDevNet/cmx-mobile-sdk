//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___FILEBASENAME___.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ___FILEBASENAME___

#define kServerBaseURL @"___VARIABLE_ServerBaseURL___"


#pragma mark UIApplication delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure CMX client with app settings
    CMXClientConfiguration* configuration = [self configuration];
    if([___FILEBASENAME___ checkConfiguration:configuration]) {
        [CMXClient instance].configuration = configuration;
    }
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(CMXClientConfiguration*) configuration {
    CMXClientConfiguration *config = [[CMXClientConfiguration alloc] init];
    config.serverURL = [NSURL URLWithString:kServerBaseURL];

    return config;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Check if the given configuration is valid
+(BOOL) checkConfiguration:(CMXClientConfiguration*)configuration {
    BOOL res = configuration.serverURL != nil;
    if(!res) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CMX Warning Alert Title", @"") message:NSLocalizedString(@"CMX Invalid configuration", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CMX OK Button", @"") otherButtonTitles:nil];
        [alertView show];
    }
    return res;
}

@end
