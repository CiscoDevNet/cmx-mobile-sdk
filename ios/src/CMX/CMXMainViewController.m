//
//  CMXMainViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXMainViewController.h"
#import "CMXFloorViewController.h"
#import "CMXMenuViewController.h"
#import "CMXSettingsViewController.h"
#import "CMXSearchViewController.h"
#import "CMXPoiViewController.h"
#import "CMXVenue.h"
#import "CMXFloor.h"
#import "CMXPoi.h"
#import "CMXClientLocation.h"
#import "CMXClient.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXMainViewController ()

/**
 *  Central view controller
 **/
@property (nonatomic,strong) CMXFloorViewController *floorViewcontroller;

/**
 *  Menu view controller (left panel)
 **/
@property (nonatomic,strong) CMXMenuViewController *menuViewController;

/**
 *  Search view controller (right panel)
 **/
@property (nonatomic,strong) CMXSearchViewController *searchViewController;

/**
 *  Ordered venues (as returned by CMX server)
 */
@property (nonatomic,strong) NSArray* orderedVenues;

/**
 *  Dictionary of venues (key = venue id)
 */
@property (nonatomic,strong) NSDictionary* venuesById;

/**
 *  Ordered array of floors (as returned by CMX server) for each venue (key = venue id)
 */
@property (nonatomic,strong) NSDictionary* floorsByVenueId;

/**
 *  Current venue id or nil if none
 */
@property (nonatomic,strong) NSString* currentVenueId;

/**
 *  Current floor id or nil if none
 */
@property (nonatomic,strong) NSString* currentFloorId;

/**
 *  Last client location
 */
@property (nonatomic,strong) CMXClientLocation* lastClientLocation;

/**
 *  Poi target destination.
 */
@property (nonatomic,strong) CMXPoi* targetDestination;

@property (nonatomic, strong) NSString* initialClientVenueId;
@property (nonatomic, strong) NSString* initialClientFloorId;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXMainViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithVenues:(NSArray*)venues floorsByVenueId:(NSDictionary *)floorsByVenueId userLocation:(CMXClientLocation *)userLocation {
    self = [super init];
    if (self) {
        // Custom initialization
        [self adjustLatteralViewSizeAndVisibility];

        self.orderedVenues = venues;
        self.floorsByVenueId = floorsByVenueId;

        NSMutableDictionary* venuesById = [NSMutableDictionary dictionaryWithCapacity:venues.count];
        for(CMXVenue* venue in venues) {
            [venuesById setObject:venue forKey:venue.identifier];
        }
        self.venuesById = venuesById;

        // Check if we know the venue & floor where the user is
        if(userLocation) {
            self.initialClientVenueId = userLocation.venueId;
            self.initialClientFloorId = userLocation.floorId;
        }
        else {
            // If not, get the first venue/floor
            CMXVenue* userVenue = [venues objectAtIndex:0];
            CMXFloor* userFloor = [[floorsByVenueId objectForKey:userVenue.identifier] objectAtIndex:0];
            self.initialClientVenueId = userVenue.identifier;
            self.initialClientFloorId = userFloor.identifier;
        }
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidLoad {
    [super viewDidLoad];

    CMXVenue* venue = [self venueWithId:_initialClientVenueId];
    CMXFloor* floor = [self floorWithId:_initialClientFloorId ofVenue:_initialClientVenueId];

    // Menu controller
    self.menuViewController = [[CMXMenuViewController alloc] initWithStyle:UITableViewStylePlain];
    [_menuViewController setupWithVenues:_orderedVenues floors:_floorsByVenueId userLocation:[CMXClient instance].clientLocation];
    _menuViewController.delegate = self;
    self.leftPanel = _menuViewController;

    // Content controller
    self.floorViewcontroller = [[CMXFloorViewController alloc] initWithFloor:floor ofVenue:venue];
    _floorViewcontroller.delegate = self;
    self.centerPanel = [[UINavigationController alloc] initWithRootViewController:_floorViewcontroller];

    self.shouldDelegateAutorotateToVisiblePanel = TRUE;

    self.currentVenueId = _initialClientVenueId;
    self.currentFloorId = _initialClientFloorId;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self showCenterPanelAnimated:FALSE];
    [self adjustLatteralViewSizeAndVisibility];
}

#pragma mark - Public
////////////////////////////////////////////////////////////////////////////////////////////////////
-(CMXVenue*) venueWithId:(NSString*)venueId {
    return [_venuesById objectForKey:venueId];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(CMXFloor*) floorWithId:(NSString*)floorId ofVenue:(NSString*)venueId {
    NSArray* floors = [_floorsByVenueId objectForKey:venueId];
    for (CMXFloor* floor in floors) {
        if([floor.identifier isEqualToString:floorId]) {
            return floor;
        }
    }
    return nil;
}

#pragma mark - CMXMenuViewController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) menuViewController:(CMXMenuViewController*)controller didSelectFloorMenuItem:(NSString*)floorId ofVenue:(NSString *)venueId {

    self.currentVenueId = venueId;
    self.currentFloorId = floorId;

    [self showCenterPanelAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) menuViewControllerDidSelectSettingsMenuItem:(CMXMenuViewController*)controller {
    CMXSettingsViewController *settings = [[CMXSettingsViewController alloc] initWithNibName:@"CMXSettingsViewController" bundle:nil];  // TODO nib name
    [self showCenterPanelAnimated:YES];
    [_floorViewcontroller.navigationController pushViewController:settings animated:YES];

}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) menuViewControllerDidSelectUserLocationMenuItem:(CMXMenuViewController*)controller {

    if(_lastClientLocation) {
        self.currentVenueId = _lastClientLocation.venueId;
        self.currentFloorId = _lastClientLocation.floorId;
    }

    [self showCenterPanelAnimated:YES];
}

#pragma mark - CMXSearchViewController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) searchViewController:(CMXSearchViewController*)controller didSelectPoi:(CMXPoi*)poi {

    // Check if selected poi is on current map
    if([poi.venueId isEqualToString:_currentVenueId] && [poi.floorId isEqualToString:_currentFloorId]) {
        // Center the map on selected poi
        [_floorViewcontroller.mapView centerOnPoi:poi animated:NO];
        [_floorViewcontroller.mapView displayCalloutOnPoi:poi animated:NO];
    }
    else {
        // If not, change current map
        CMXFloor* floor = [self floorWithId:poi.floorId ofVenue:poi.venueId];
        self.currentVenueId = floor.venueId;
        self.currentFloorId = floor.identifier;

        [_floorViewcontroller.mapView centerOnPoi:poi animated:NO];
        [_floorViewcontroller.mapView displayCalloutOnPoi:poi animated:NO];
    }

    [self showCenterPanelAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) searchViewController:(CMXSearchViewController*)controller accessoryButtonTappedForPoi:(CMXPoi*)poi {

    _targetDestination = poi;

    // Check if selected poi is available on current map
    if([poi.venueId isEqualToString:_currentVenueId] && [poi.floorId isEqualToString:_currentFloorId]) {
        // Set target destination to display path
        [_floorViewcontroller setTargetDestination:poi.identifier];
        [_floorViewcontroller.mapView displayCalloutOnPoi:poi animated:NO];
    }
    else {
        // If not, change current map
        CMXFloor* floor = [self floorWithId:poi.floorId ofVenue:poi.venueId];
        self.currentVenueId = floor.venueId;
        self.currentFloorId = floor.identifier;

        // Set target destination to display path
        [_floorViewcontroller setTargetDestination:poi.identifier];
        [_floorViewcontroller.mapView displayCalloutOnPoi:poi animated:NO];
    }

    [self showCenterPanelAnimated:YES];
}

#pragma mark - CMXPoiViewController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) poiViewController:(CMXPoiViewController *)controller didSelectTargetDestination:(NSString *)poiId {

    [_floorViewcontroller setTargetDestination:poiId];

    [self showCenterPanelAnimated:YES];

    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CMXFloorViewController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) floorViewController:(CMXFloorViewController *)controller didSelectPoi:(NSString *)poiId {

    CMXPoi* poi = [_floorViewcontroller poiWithId:poiId];
    UIImage* image = [_floorViewcontroller imageOfPoi:poiId];
    CMXPoiViewController* poiViewController = [[CMXPoiViewController alloc] initWithPoi:poi image:image];
    poiViewController.title = NSLocalizedString(@"CMX Poi Controller Title", @"");
    poiViewController.delegate = self;

    [controller.navigationController pushViewController:poiViewController animated:YES];
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) adjustLatteralViewSizeAndVisibility {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    CGFloat latteralViewVisiblePercentage = 0.;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        latteralViewVisiblePercentage = 0.35;
    }else{
        latteralViewVisiblePercentage = 0.85;
    }
    
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            self.rightGapPercentage = 0.35;
            self.leftGapPercentage = 0.35;
            }else{
                self.rightGapPercentage = 0.52;
                self.leftGapPercentage = 0.52;
            }
            [self setShouldResizeRightPanel:YES];
            [self setShouldResizeLeftPanel:YES];
            break;
        case UIInterfaceOrientationLandscapeRight:
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
                self.rightGapPercentage = 0.35;
                self.leftGapPercentage = 0.35;
            }else{
                self.rightGapPercentage = 0.52;
                self.leftGapPercentage = 0.52;
            }

            [self setShouldResizeRightPanel:YES];
            [self setShouldResizeLeftPanel:YES];
            break;
        case UIInterfaceOrientationPortrait:
            self.rightGapPercentage = latteralViewVisiblePercentage;
            self.leftGapPercentage = latteralViewVisiblePercentage;
            [self setShouldResizeRightPanel:YES];
            [self setShouldResizeLeftPanel:YES];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            
            self.rightGapPercentage = latteralViewVisiblePercentage;
            self.leftGapPercentage = latteralViewVisiblePercentage;
            [self setShouldResizeRightPanel:YES];
            [self setShouldResizeLeftPanel:YES];
            break;
        default:
            
            break;
    }
    
    [self.rightPanel removeFromParentViewController];
    self.rightPanel = nil;  // Set to nil to force assignment below
    self.rightPanel = [[UINavigationController alloc] initWithRootViewController:_searchViewController];
    
    [self.leftPanel removeFromParentViewController];
    self.leftPanel = nil;  // Set to nil to force assignment below
    self.leftPanel = _menuViewController;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setCurrentVenueId:(NSString *)currentVenueId {
    if(![currentVenueId isEqualToString:_currentVenueId]) {
        _currentVenueId = currentVenueId;

        // Create Search controller
        self.searchViewController = [[CMXSearchViewController alloc] initWithVenue:[self venueWithId:currentVenueId]];
        _searchViewController.delegate = self;
        self.rightPanel = [[UINavigationController alloc] initWithRootViewController:_searchViewController];
        UIBarButtonItem *rightPanelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(rightPanelItemAction)];
        _floorViewcontroller.navigationItem.rightBarButtonItem = rightPanelItem;

        // We must update user location polling with venue's settings
        CMXVenue* currentVenue = [self venueWithId:_currentVenueId];
        if(currentVenue && [[CMXClient instance] isRegistered]) {
            [[CMXClient instance] startUserLocationPollingWithInterval:currentVenue.locationUpdateInterval update:^void(CMXClientLocation *clientLocation) {
                // Check if client is located in a new floor/venue.
                if(![clientLocation.floorId isEqualToString:_lastClientLocation.floorId] || ![clientLocation.venueId isEqualToString:_lastClientLocation.venueId]) {
                    CMXFloor* floor = [self floorWithId:clientLocation.floorId ofVenue:clientLocation.venueId];
                    [_menuViewController updateMenuItemsWithNewCurrentFloor:floor];
                }
                else if(!clientLocation) {
                    [_menuViewController updateMenuItemsWithNewCurrentFloor:nil];
                }

                // Update floor controller with new location
                [_floorViewcontroller setClientLocation:clientLocation];

                // Save the new location as last known location.
                self.lastClientLocation = clientLocation;
            }];
        }
        else {
            [[CMXClient instance] stopUserLocationPolling];
            self.lastClientLocation = nil;
            [_menuViewController updateMenuItemsWithNewCurrentFloor:nil];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setCurrentFloorId:(NSString *)currentFloorId {
    if(![_currentFloorId isEqualToString:currentFloorId]) {
        _currentFloorId = currentFloorId;

        CMXVenue* venue = [self venueWithId:_currentVenueId];
        CMXFloor* floor = [self floorWithId:currentFloorId ofVenue:_currentVenueId];
        [_floorViewcontroller updateControllerWithFloor:floor ofVenue:venue];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) rightPanelItemAction {
    [self showRightPanelAnimated:(self.state != JASidePanelRightVisible)];
}

@end
