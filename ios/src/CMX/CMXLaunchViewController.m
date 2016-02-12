//
//  LaunchViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXLaunchViewController.h"
#import "Model.h"

#import "CMXClient.h"

#import "CMXNotifications.h"

#import "CMXLoadingView.h"

#import "CMXUtils.h"

#import "CMXMenuViewController.h"
#import "CMXFloorViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXLaunchViewController ()

/** Venues Array. */
@property (nonatomic,strong) NSArray *venues;

/** Floors by venue Id. */
@property (nonatomic,strong) NSDictionary *floorsByVenueId;

/** The User Location. */
@property (nonatomic,strong) CMXClientLocation *userLocation;

/** Reload bouton. */
@property (nonatomic,strong) IBOutlet UIButton *reloadButton;

/** Loading indicator. */
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *loadingIndicatorView;

/** Notification observer. */
@property (nonatomic,strong) id removeNotificationsDidRegisterObserver;

/** Notification observer. */
@property (nonatomic,strong) id removeNotificationsDidFailToRegisterObserver;

@property (nonatomic,assign) BOOL registrationHasFinished;
@property (nonatomic,assign) BOOL floorsHasFinished;
@property (nonatomic,assign) BOOL userLocationHasFinished;

@property (nonatomic,assign) UIAlertView* registeringAlertView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXLaunchViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_removeNotificationsDidRegisterObserver name:CMXRemoteNotificationsDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:_removeNotificationsDidFailToRegisterObserver name:CMXRemoteNotificationsDidFailToRegisterNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.removeNotificationsDidRegisterObserver = [[NSNotificationCenter defaultCenter]
                                                   addObserverForName:CMXRemoteNotificationsDidRegisterNotification
                                                   object:nil
                                                   queue:[NSOperationQueue mainQueue]
                                                   usingBlock:^(NSNotification *note) {
                                                       NSData* deviceToken = [note.userInfo objectForKey:CMXRemoteNotificationsDeviceTokenKey];
                                                       // Updates the device token and registers the token with CMX server.
                                                       [[CMXClient instance] registerDeviceToken:deviceToken];

                                                       // Force registeration with new device token
                                                       [self registerDevice];
                                                       /*
                                                       [[CMXClient instance] registerDeviceToken:deviceToken
                                                                                      completion:^(BOOL registeredForGeolocation) {
                                                                                          _registrationHasFinished = YES;
                                                                                          [self loadUserLocation];
                                                                                      }
                                                                                         failure:^(NSError* error) {
                                                                                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Warning Alert Title", @"")
                                                                                                                                                 message: NSLocalizedString(@"CMX Registering Error", @"")
                                                                                                                                                delegate: self
                                                                                                                                       cancelButtonTitle: nil
                                                                                                                                       otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                                                                             self.registeringAlertView = alertView;
                                                                                             [alertView show];

                                                                                         }];
                                                        */
                                                   }];

    self.removeNotificationsDidFailToRegisterObserver = [[NSNotificationCenter defaultCenter]
                                                         addObserverForName:CMXRemoteNotificationsDidFailToRegisterNotification
                                                         object:nil
                                                         queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification *note) {

                                                             // Force registeration without device token
                                                             [self registerDevice];

                                                             //NSError* error = [note.userInfo objectForKey:CMXRemoteNotificationsErrorKey];
                                                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                                                 message: NSLocalizedString(@"CMX Notifications Registering Error", @"")
                                                                                                                delegate: self
                                                                                                       cancelButtonTitle: nil
                                                                                                       otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                                             self.registeringAlertView = alertView;
                                                             [alertView show];

                                                         }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self loadData];
}

#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction) reloadButtonAction:(id)sender {
    
    [self loadData];
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadData {
    
    _registrationHasFinished = [[CMXClient instance] isRegistered] && [[CMXClient instance] isRegisteredForRemoteNotifications];
    _floorsHasFinished = NO;
    _userLocationHasFinished = NO;
    
    [self loadingDidStart];
/*
    if(![[CMXClient instance] isRegistered]) {
        [[CMXClient instance] registerForRemoteNotifications];
    }
    else {
        [self loadUserLocation];
    }
*/
    [self loadVenues];

    // If device has already been registered, try to load client location
    if([[CMXClient instance] isRegistered]) {
        [self loadUserLocation];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) registerDevice {
    NSMutableArray* networks = [NSMutableArray array];
    for(CMXVenue* venue in _venues) {
        [networks addObjectsFromArray:venue.preferredNetworks];
    }

    [[CMXClient instance] registerWithAppServerWithCompletion:^{
                                       _registrationHasFinished = YES;
                                       [self loadUserLocation];
                                   }
                                      failure:^(NSError* error) {
                                          if(IS_IOS_7_OR_LATER) {
                                              UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Warning Alert Title", @"")
                                                                                                  message: NSLocalizedString(@"CMX Registering Error, Not Connected To CMX Wi-Fi", @"")
                                                                                                 delegate: self
                                                                                        cancelButtonTitle: nil
                                                                                        otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                              self.registeringAlertView = alertView;
                                              [alertView show];
                                          }
                                          else {
                                              UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Warning Alert Title", @"")
                                                                                                  message: NSLocalizedString(@"CMX Registering Error", @"")
                                                                                                 delegate: self
                                                                                        cancelButtonTitle: nil
                                                                                        otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                              self.registeringAlertView = alertView;
                                              [alertView show];
                                          }
                                      }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadVenues {

    self.venues = nil;
    self.floorsByVenueId = nil;

    [[CMXClient instance] loadVenuesWithStart:nil
                                   completion:^(NSArray *venues) {

                                       self.venues = venues;
                                       [self loadFloors];

                                       if(![[CMXClient instance] isRegisteredForRemoteNotifications]) {
                                           [[CMXClient instance] registerForRemoteNotifications];
                                       }
                                       else {
                                           if(![[CMXClient instance] isRegistered]) {
                                               [self registerDevice];
                                           }
                                       }
                                   }
                                      failure:^(NSError *error) {
                                          [self loadingDidFailWithError:error];
                                      }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadFloors {
    
    self.floorsByVenueId = [NSMutableDictionary dictionary];
    
    for (CMXVenue *venue in self.venues) {
        [[CMXClient instance] loadFloorsOfVenue:venue.identifier
                                          start:nil
                                     completion:^(NSArray *floors) {
                                         
                                         [_floorsByVenueId setValue:floors forKey:venue.identifier];

                                         _floorsHasFinished = _floorsByVenueId.count == _venues.count;
                                         
                                         [self checkIfLoadingDidFinish];
                                         
                                     } failure:^(NSError *error) {
                                         [self loadingDidFailWithError:error];
                                     }];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadUserLocation {
    self.userLocation = nil;
    
    [[CMXClient instance] loadUserLocationWithCompletion:^(CMXClientLocation *clientLocation) {
        _userLocation = clientLocation;
        _userLocationHasFinished = YES;
        [self checkIfLoadingDidFinish];
    }
                                                 failure:^(NSError* error) {
                                                     _userLocationHasFinished = YES;
                                                     [self checkIfLoadingDidFinish];
                                                 }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) checkIfLoadingDidFinish {
    if(_registrationHasFinished && _floorsHasFinished && _userLocationHasFinished) {
        if (self.onDataLoaded) {
            self.onDataLoaded(_venues, _floorsByVenueId, self.userLocation);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadingDidStart {
    _reloadButton.hidden = YES;
    _loadingIndicatorView.hidden = NO,
    [_loadingIndicatorView startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadingDidFinish {
    _reloadButton.hidden = YES;
    _loadingIndicatorView.hidden = YES,
    [_loadingIndicatorView stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadingDidFailWithError:(NSError*)error {
    [_loadingIndicatorView stopAnimating];
    _loadingIndicatorView.hidden = YES;
    _reloadButton.hidden = NO;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                        message: error.localizedDescription
                                                       delegate: nil
                                              cancelButtonTitle: nil
                                              otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
    [alertView show];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(_registeringAlertView == alertView) {
        _registrationHasFinished = YES;
        _userLocationHasFinished = YES;
        _registeringAlertView = nil;
        [self checkIfLoadingDidFinish];
    }
}

@end
