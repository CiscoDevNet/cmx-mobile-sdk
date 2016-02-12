//
//  CMXSettingsViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXSettingsViewController.h"
#import "CMXClient.h"
#import "CMXClientConfiguration.h"
#include <arpa/inet.h>

static NSString *SERVER_URL_KEY = @"serverURL";


@interface CMXSettingsViewController()

//placeholder for the serverIP
@property (strong,nonatomic) UITextField *serverIP;
@property (strong,nonatomic) UITextField *serverPort;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXSettingsViewController


////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //this is the textfield which will hold the serverIP
    _serverIP = [[UITextField alloc] initWithFrame:CGRectMake(120, 130, 180, 30)];
    _serverIP.borderStyle = UITextBorderStyleRoundedRect;
    _serverIP.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:15];
    _serverIP.backgroundColor=[UIColor whiteColor];
    _serverIP.delegate = self;
    [self.view addSubview:self.serverIP];
    
    //this is the textfield which will hold the server port
    _serverPort = [[UITextField alloc] initWithFrame:CGRectMake(120, 179, 180, 30)];
    _serverPort.borderStyle = UITextBorderStyleRoundedRect;
    _serverPort.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:15];
    _serverPort.backgroundColor=[UIColor whiteColor];
    _serverPort.delegate = self;
    _serverPort.text = @"8082";
    [self.view addSubview:self.serverPort];
    
    //this is the set button which will trigger the action to set the cloud server
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Set" forState:UIControlStateNormal];
    button.frame = CGRectMake(250.0, 220.0, 36.0, 30.0);
    [self.view addSubview:button];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction)enableNotificationSwitchvalueChanged:(id)sender {
    UISwitch *switchSend = (UISwitch*)sender;
    
    if (switchSend.on) {
        [[CMXClient instance] registerForRemoteNotifications];
    }else{
        [[CMXClient instance] unregisterForRemoteNotifications];
    }
}

- (void)buttonPressed: (id)sender {
    
    [self setServerAddress];
    
}

- (BOOL) checkIPFormat: (NSString*) ipAddress {
    
    const char* utf8 = [ipAddress UTF8String];
    
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return (success == 1 );
    
}

-(void) setServerAddress {
    
    bool correctIPFormat = [self checkIPFormat:self.serverIP.text];
    
    //check server IP address for v4 and v6
    if (correctIPFormat) {
        
        //create the correct IP string
        
        NSString* serverBaseUrl = [NSString stringWithFormat:@"%@%@%@%@",@"https://",self.serverIP.text,@":",self.serverPort.text];
        
        [[NSUserDefaults standardUserDefaults] setObject:serverBaseUrl forKey:SERVER_URL_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Success Alert Title", @"")
                                                        message: serverBaseUrl
                                                       delegate: self
                                              cancelButtonTitle: nil
                                              otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
    [alertView show];
        
        
    }else{
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                            message: @"Invalid IP Address"
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
        [alertView show];
    }

    
}



@end
