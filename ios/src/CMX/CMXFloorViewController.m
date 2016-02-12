//
//  CMXFloorViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXFloorViewController.h"
#import "CMXSearchViewController.h"

#import "CMXMapView.h"
#import "CMXLoadingView.h"

#import "CMXClient.h"
#import "CMXFloor.h"
#import "CMXVenue.h"
#import "CMXPoi.h"
#import "CMXClientLocation.h"
#import "CMXVenue.h"
#import "CMXBanner.h"

#import "CMXDebug.h"

#import "CMXBannerViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "CMXPoiViewController.h"

#define kFilteringFactor 0.05

#define kBannerDisplayTime 4.

#pragma mark - CMXFloorViewController
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXFloorViewController () < CLLocationManagerDelegate>

/** Map view. */
@property (nonatomic,strong) CMXMapView* mapView;

/** Banner controller **/
@property (nonatomic,strong) CMXBannerViewController* bannerViewController;

/** Location Manager */
@property (nonatomic,strong) CLLocationManager* locationManager;

/** Floor model */
@property (nonatomic,strong) CMXFloor* floor;

/** Venue model */
@property (nonatomic,strong) CMXVenue* venue;

/** Pois of the floor (key = poi identifier). */
@property (nonatomic,strong) NSDictionary* pois;

/** Active poi identifier. */
@property (nonatomic,strong) NSString* activePoiIdentifier;

/** Last search result. */
@property (nonatomic,strong) NSArray* searchResult;

/** Images of the pois (key = poi identifier). */
@property (nonatomic,strong) NSMutableDictionary* poisImages;

/** Poi's id of the active target destination */
@property (nonatomic,strong) NSString *poiTargetId;

/** Poi identifier of the active target */
@property (nonatomic,assign) BOOL shouldShowNavBar;     // TODO ???

/** Last zoneId */
@property (nonatomic,strong) NSString *lastZoneId;

@property (nonatomic,strong) UIAlertView* postFeedbackAlertView;

@property (nonatomic,assign) CGPoint feedbackLocation;

@property (nonatomic, strong) UIImage* userLocationImage;
@property (nonatomic, strong) UIImage* orientedUserLocationImage;
@property (nonatomic, strong) UIImage* pathImage;
@property (nonatomic, strong) UIColor* pathColor;
@property (nonatomic, assign) NSUInteger pathLineWidth;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXFloorViewController

#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithFloor:(CMXFloor *)floor ofVenue:(CMXVenue *)venue {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.floor = floor;
        self.venue = venue;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidLoad {
    [super viewDidLoad];

    self.userLocationImage = [UIImage imageNamed:@"cmx_user_location.png"];
    self.orientedUserLocationImage = [UIImage imageNamed:@"cmx_user_direction.png"];
    self.pathImage = [UIImage imageNamed:@"cmx_target_location.png"];
    self.pathColor = [UIColor colorWithRed:51/255.0f green:170/255.0f blue:0/255.0f alpha:1.0f];
    self.pathLineWidth = 5;

    _shouldShowNavBar = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:153/255.0f blue:204/255.0f alpha:1.0f];
    
    self.mapView = [[CMXMapView alloc] initWithFrame:self.view.bounds];
    _mapView.mapDelegate = self;
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapView setLocationFeedbackImage:[UIImage imageNamed:@"cmx_feedback_user_location.png"]];

    self.bannerViewController = [[CMXBannerViewController alloc] init];
    _bannerViewController.view.frame = CGRectMake(0, self.view.frame.size.height - _bannerViewController.view.frame.size.height, self.view.frame.size.width, _bannerViewController.view.frame.size.height);
    [self.view addSubview:_bannerViewController.view];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
    }

    [self.view addSubview:_mapView];
    
    // Initialize heading manager is heading is available only
    if([CLLocationManager headingAvailable]) {
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = 1;
        _locationManager.delegate = self;
    }

    [self loadMapData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start heading manager if available
    if(_locationManager) {
        [_locationManager startUpdatingHeading];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewWillDisappear:(BOOL)animated{
    if(self.navigationController && _shouldShowNavBar)
        [self.navigationController setNavigationBarHidden:NO animated:animated];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.navigationController && _shouldShowNavBar)
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Stop heading manager if available
    if(_locationManager) {
        [_locationManager stopUpdatingHeading];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [_mapView updateMinMaxZoomScales];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    if(_activePoiIdentifier) {
        [self.mapView centerOnPoi:[self poiWithId:_activePoiIdentifier] animated:YES];
    }
}

#pragma mark - CMXMapView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) mapView:(CMXMapView *)mapView didSelectPoi:(NSString *)poiId {
    CMXPoi* poi = [self poiWithId:poiId];
    [self setActivePoi:poi centerOnMap:NO];

    [_mapView displayCalloutOnPoi:poi animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) mapView:(CMXMapView *)mapView didDisclosePoi:(NSString *)poiId {

    if([_delegate respondsToSelector:@selector(floorViewController:didSelectPoi:)]) {
        [_delegate floorViewController:self didSelectPoi:poiId];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) mapView:(CMXMapView*)mapView didSetLocationFeedback:(CGPoint)location {
    self.feedbackLocation = location;

    if(!_postFeedbackAlertView) {
        self.postFeedbackAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Information Alert Title", @"")
                                                                message: NSLocalizedString(@"CMX Posting Location Feedback Question", @"")
                                                               delegate: self
                                                      cancelButtonTitle: NSLocalizedString(@"CMX No Button", @"")
                                                      otherButtonTitles: NSLocalizedString(@"CMX Yes Button", @""), nil];
        [_postFeedbackAlertView show];
    }
}

#pragma mark - Public
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updateControllerWithFloor:(CMXFloor *)floor ofVenue:(CMXVenue *)venue {
    self.venue = venue;
    self.floor = floor;
    [self.mapView cleanMapView];
    [self loadMapData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setTargetDestination:(NSString*)poiId {
    self.poiTargetId = poiId;

    [self updatePathToTargetDestination];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setClientLocation:(CMXClientLocation*)location {
    if([location.floorId isEqualToString:_floor.identifier]) {

        [_mapView showUserLocation:location withImage:[self userLocationImage]];

        // If there is an active target, update the path to this target
        [self updatePathToTargetDestination];
    }
    else {
        // Client is not located on current floor, we don't show the location on map
        [_mapView showUserLocation:nil withImage:nil];
    }

    // Check if client has moved to a new zone
    if (![_lastZoneId isEqualToString:location.zoneId]) {
        self.lastZoneId = location.zoneId;
        if(_lastZoneId) {
            // If so, load banner data
            [self loadBannerData];
        }
        else {
            // There is no zone id where client is located, hide banners
            [self showBanners:NO];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(CMXPoi*) poiWithId:(NSString*)poiId {
    return [_pois objectForKey:poiId];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIImage*) imageOfPoi:(NSString*)poiId {
    return [_poisImages objectForKey:poiId];
}

#pragma mark - Location Manager delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    static float heading = 1.f;
    
	// Use a basic low-pass gravity filter to keep only the gravity component of each axis.
    heading = (newHeading.trueHeading * kFilteringFactor) + (heading * (1.0 - kFilteringFactor));
    
    if([CMXClient instance].clientLocation) {
        [_mapView showUserLocation:[CMXClient instance].clientLocation withOrientation:heading image:[self orientedUserLocationImage]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(_postFeedbackAlertView == alertView) {
        self.postFeedbackAlertView = nil;

        if(buttonIndex != [_postFeedbackAlertView cancelButtonIndex]) {
            __block CMXLoadingView* loadingView = nil;
            // Location feedback has changed, post the new value to the CMX server
            [[CMXClient instance] postLocationFeedback:_feedbackLocation
                                                 start:^() {
                                                     loadingView = [CMXLoadingView loadingViewInView:self.view withTitle:NSLocalizedString(@"CMX Posting Location Feedback Message", @"")];
                                                 }
                                            completion:^() {
                                                [loadingView removeView];
                                                [_mapView cleanLocationFeedback];
                                            }
                                               failure:^(NSError *error) {
                                                   [loadingView removeView];
                                                   UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                                       message: error.localizedDescription
                                                                                                      delegate: self
                                                                                             cancelButtonTitle: nil
                                                                                             otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                                   [alertView show];
                                               }];
        }
    }
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadMapData {
    __block CMXLoadingView* loadingView = nil;
    [[CMXClient instance] loadImageOfFloor:_floor.identifier
                                   ofVenue:_floor.venueId
                                     start:^() {
                                         loadingView = [CMXLoadingView loadingViewInView:self.view withTitle:NSLocalizedString(@"CMX Loading Message", @"")];
                                     }
                                completion:^(UIImage* image) {
                                    self.title = _floor.name;
                                    [loadingView removeView];
                                    
                                    [self.mapView setupWithMapImage:image mapDimension:_floor.dimension];

                                    [self loadPois];
                                    //[self loadUserPosition];
                                }
                                   failure:^(NSError *error) {
                                       [loadingView removeView];
                                       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                           message: error.localizedDescription
                                                                                          delegate: self
                                                                                 cancelButtonTitle: nil
                                                                                 otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                       [alertView show];
                                   }];
    if(_lastZoneId)
        [self loadBannerData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadBannerData {
    
    [[CMXClient instance] loadBannersForZone:_lastZoneId
                                     ofVenue:_venue.identifier
                                       floor:_floor.identifier
                                       start:nil
                                  completion:^(NSArray *banners) {

                                      if (banners.count > 0) {

                                          NSMutableArray *bannerImages = [NSMutableArray arrayWithCapacity:banners.count];

                                          // Fill array with null objects before loading images
                                          for (CMXBanner* banner in banners) {
                                              [bannerImages addObject:[NSNull null]];
                                          }
                                          
                                          NSUInteger index = 0;
                                          for (CMXBanner* banner in banners) {
                                              [[CMXClient instance] loadBannerImageForImage:banner.imageId
                                                                                    ofVenue:banner.venueId
                                                                                      floor:_floor.identifier
                                                                                       zone:banner.zoneId
                                                                                      start:nil
                                                                                 completion:^(UIImage *bannerImage) {
                                                                                     
                                                                                     [bannerImages replaceObjectAtIndex:index withObject:bannerImage];
                                                                                     
                                                                                     if (![bannerImages containsObject:[NSNull null]]) {
                                                                                         [_bannerViewController setBannerImages:bannerImages imageDuration:kBannerDisplayTime];
                                                                                         [self showBanners:YES];
                                                                                     }
                                                                                     
                                                                                 } failure:^(NSError *error) {
                                                                                     CMXLogD(@"Error loading banner image : %@", error.description);
                                                                                     
                                                                                     [bannerImages removeObjectAtIndex:index];
                                                                                     
                                                                                     if (![bannerImages containsObject:[NSNull null]]) {
                                                                                         [_bannerViewController setBannerImages:bannerImages imageDuration:kBannerDisplayTime];
                                                                                         [self showBanners:YES];
                                                                                     }
                                                                                 }];
                                              ++index;
                                          }
                                      }else{
                                          [self showBanners:NO];
                                      }
                                      
                                  } failure:^(NSError *error) {
                                      CMXLogD(@"Error : %@", error.description);
                                  }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) loadPois {
    __block CMXLoadingView* loadingView = nil;
    
    self.pois = nil;
    self.activePoiIdentifier = nil;
    self.searchResult = nil;
    self.poisImages = [NSMutableDictionary dictionary];
    self.poiTargetId = nil;
    
    [self.mapView cleanMapView];
    
    //Load all maps of the venue
    [[CMXClient instance] loadPoisOfFloor:_floor.identifier
                                  ofVenue:_floor.venueId
                                    start:^{
                                        // Show loading indicator
                                        loadingView = [CMXLoadingView loadingViewInView:self.view withTitle:NSLocalizedString(@"CMX Loading Message", @"")];
                                     
                                        
                                    } completion:^(NSArray* pois) {
                                        
                                      
                                        [loadingView removeView];
                                        
                                        NSMutableDictionary* validPois = [NSMutableDictionary dictionaryWithCapacity:pois.count];

                                        // Keep only poi with image
                                        for(CMXPoi* poi in pois) {
                                            if (![poi.imageType isEqualToString:@"none"]) {
                                                [validPois setObject:poi forKey:poi.identifier];
                                            }
                                        }
                                        
                                        self.pois = validPois;
                                        [self updatePois];
                                    }
                                  failure:^(NSError *error) {
                                    
                                      [loadingView removeView];
                                      
                                      UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                          message: error.localizedDescription
                                                                                         delegate: self
                                                                                cancelButtonTitle: nil
                                                                                otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                      [alertView show];
                                  }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updatePathToTargetDestination {
    if(_poiTargetId) {
        // Search navigation path to selected poi
        [[CMXClient instance] loadPathForPoi:_poiTargetId
                                       start:nil
                                  completion:^(CMXPath *path) {

                                      [self.mapView showPath:path withColor:[self pathColor] lineWith:[self pathLineWidth] targetImage:[self pathImage]];
                                  }
                                     failure:^(NSError *error) {
                                         CMXLogD(@"Load Path error ::: %@",error.localizedDescription);

                                         [self.mapView showPath:nil withColor:nil lineWith:[self pathLineWidth] targetImage:nil];

                                         self.poiTargetId = nil;

                                         UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                             message: error.localizedDescription
                                                                                            delegate: nil
                                                                                   cancelButtonTitle: nil
                                                                                   otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                         [alertView show];
                                     }];
    }
    else {
        [self.mapView showPath:nil withColor:[self pathColor] lineWith:[self pathLineWidth] targetImage:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) showPoiOnMap:(CMXPoi*)poi {
    // Check if the image has already been downloaded
    if([_poisImages objectForKey:poi.identifier]) {
        // Show image for this poi on map view
        [self.mapView showPOI:poi withImage:[_poisImages objectForKey:poi.identifier]];
    }
    else {
        // Start asynchronous loading of the image
        [[CMXClient instance] loadImageOfPoi:poi.identifier
                                     ofVenue:_venue.identifier
                                       start:nil
                                  completion:^(UIImage *image) {
                                      // Store the image for future usage
                                      [_poisImages setObject:image forKey:poi.identifier];
                                      
                                      // Show image for this poi on map view
                                      [self.mapView showPOI:poi withImage:image];
                                  }
                                     failure:^(NSError *error) {
                                         CMXLog(@"Image loading failed : %@", error.debugDescription);
                                         // Do nothing with invalid image
                                     }];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setActivePoi:(CMXPoi*)poi centerOnMap:(BOOL)center {
    self.activePoiIdentifier = poi.identifier;
 
    if(poi) {
        if(center) {
            [self.mapView centerOnPoi:poi animated:YES];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updatePois {
    [_mapView cleanMapView];
    
    // Check if we have a search result. In this case, active pois are those from search result
    if(_searchResult) {
        // Sort result in alphabetically order
        NSArray* filteredPois = [self alphabeticalOrderPoisSorting:_searchResult];
        
        for(CMXPoi* poi in filteredPois) {
            [self showPoiOnMap:poi];
        }
        
        CMXPoi* active = filteredPois.count ? [filteredPois objectAtIndex:0] : nil;
        [self setActivePoi:active centerOnMap:YES];
    }
    else { // No search result, active pois are those of the floor
        
        // Sort pois in alphabetically order
        NSArray* filteredPois = [self alphabeticalOrderPoisSorting:[_pois allValues]];

        for(CMXPoi* poi in filteredPois) {
            [self showPoiOnMap:poi];
        }
        
        [self setActivePoi:nil centerOnMap:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*) alphabeticalOrderPoisSorting:(NSArray*)pois {
    return [pois sortedArrayUsingComparator:^NSComparisonResult(CMXPoi* first, CMXPoi* second) {
        return [first.name compare:second.name];
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) searchQuery:(NSString*)keywords {
    [[CMXClient instance] loadQueryForKeywords:keywords
                                       ofVenue:_floor.venueId
                                         start:nil
                                    completion:^(NSMutableArray *pois) {
                                        
                                        self.searchResult = pois;
                                        
                                        [self updatePois];
                                    }
                                       failure:^(NSError *error) {
                                           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                               message: error.localizedDescription
                                                                                              delegate: self
                                                                                     cancelButtonTitle: nil
                                                                                     otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                           [alertView show];
                                       }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) showBanners:(BOOL)visible {

    if (visible) {
        _bannerViewController.view.hidden = NO;
        _mapView.frame = CGRectMake(_mapView.frame.origin.x, _mapView.frame.origin.y, _mapView.frame.size.width, self.view.frame.size.height - _bannerViewController.view.frame.size.height);
        [_mapView updateMinMaxZoomScales];
    }
    else {
        _bannerViewController.view.hidden = YES;
        _mapView.frame = self.view.bounds;
        [_mapView updateMinMaxZoomScales];
    }
}

@end


