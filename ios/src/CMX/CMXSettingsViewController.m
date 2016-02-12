//
//  CMXSettingsViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXSettingsViewController.h"
#import "CMXClient.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXSettingsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction)enableNotificationSwitchvalueChanged:(id)sender {
    UISwitch *switchSend = (UISwitch*)sender;
    
    if (switchSend.on) {
        [[CMXClient instance] registerForRemoteNotifications];
    }else{
        [[CMXClient instance] unregisterForRemoteNotifications];
    }
}

@end
