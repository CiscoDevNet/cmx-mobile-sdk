//
//  CMXClient.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXClient.h"

#import "CMXClientConfiguration.h"
#import "CMXClientLocation.h"
#import "CMXFloor.h"
#import "CMXPath.h"
#import "CMXPoi.h"
#import "CMXPoint.h"
#import "CMXDebug.h"
#import "CMXVenue.h"
#import "CMXBanner.h"
#import "CMXNetwork.h"
#import "CMXUtils.h"
#import "CMXBleBeacon.h"

#import "NSString+URLEncoding.h"

#import "SvgToUIImage.h"

#import "AFNetworking.h"

#import "Reachability.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <dispatch/dispatch.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

static NSString *VENUES_URL = @"cmx-cloud-server/api/cmxmobile/v1/venues/info/";
static NSString *VENUE_URL = @"cmx-cloud-server/api/cmxmobile/v1/venues/info/%@";
static NSString *VENUE_DOWNLOAD = @"cmx-cloud-server/api/cmxmobile/v1/venues/image/%@";

static NSString *MAPS_INFO_URL = @"cmx-cloud-server/api/cmxmobile/v1/maps/info/%@";
static NSString *FLOOR_INFO_URL = @"cmx-cloud-server/api/cmxmobile/v1/maps/info/%@/%@";
static NSString *FLOOR_IMAGE_URL = @"cmx-cloud-server/api/cmxmobile/v1/maps/image/%@/%@";
static NSString *CLIENTS_LOCATION_URL = @"cmx-cloud-server/api/cmxmobile/v1/clients/location/%@";
static NSString *POIS_URL = @"cmx-cloud-server/api/cmxmobile/v1/pois/info/%@";
static NSString *POIS_IMAGE_URL = @"cmx-cloud-server/api/cmxmobile/v1/pois/image/%@/%@";
static NSString *FLOOR_POIS_URL = @"cmx-cloud-server/api/cmxmobile/v1/pois/info/%@/%@";
static NSString *SEARCH_URL = @"cmx-cloud-server/api/cmxmobile/v1/pois/info/%@?search=%@";
static NSString *PATH_URL = @"cmx-cloud-server/api/cmxmobile/v1/routes/clients/%@?destpoi=%@";
static NSString *CLIENT_REGISTERING_URL = @"cmx-cloud-server/api/cmxmobile/v1/clients/register/";
static NSString *CLIENT_LOCATION_FEEDBACK_URL = @"cmx-cloud-server/api/cmxmobile/v1/clients/feedback/location/%@";
static NSString *BANNERS_INFO_URL = @"cmx-cloud-server/api/cmxmobile/v1/banners/info/%@/%@/%@";
static NSString *BANNER_IMAGE_URL = @"cmx-cloud-server/api/cmxmobile/v1/banners/image/%@/%@/%@/%@";
static NSString *BLEBEACON_URL = @"cmx-cloud-server/api/cmxmobile/v1/blebeacons/info/%@/%@";
static NSString *BLEBEACON_VENUE_URL = @"cmx-cloud-server/api/cmxmobile/v1/blebeacons/info/%@";

static NSString *LOCATION_FEEDBACK = @"cmx-cloud-server/api/cmxmobile/v1/clients/feedback/location";




static NSString *DEVICE_TOKEN_KEY = @"deviceToken";
static NSString *DEVICE_ID_KEY = @"deviceId";

@interface CMXClient ()

/**
 *  Request Manager for HTTPS connection    
 **/
@property (nonatomic,strong) AFHTTPClient *httpsConnectionManager;

/** Network reachability */
@property (nonatomic,strong) Reachability *internetReach;

@property (nonatomic, strong) CMXClientLocation* clientLocation;

@property (nonatomic, strong) NSTimer* clientLocationRequestTimer;

/**
 *  operations queue (for data downloading)
 **/
@property (nonatomic,strong)  NSOperationQueue *operationQueue;

/**
 *   convert svg to uiimage
 **/
@property (nonatomic,strong)  SvgToUIImage *svgToUImage;


@end

@implementation CMXClient

#pragma mark INITIALISATION
////////////////////////////////////////////////////////////////////////////////////////////////////
+(CMXClient*) instance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
    self = [super init];
    if (self) {
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.clientLocation = nil;
        self.clientLocationRequestTimer = nil;
        
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [_internetReach startNotifier];
        
        [self loadCookies];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isRegistered {
    return [self deviceId] != nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)registerWithAppServerWithCompletion:(void (^)())completion
                                   failure:(FailureBlock)failure{
    //Call the venues API and get all the preferred networks
    NSMutableArray* networks = [NSMutableArray array];
    
    [self loadVenuesWithStart:nil
                   completion:^(NSArray *venues) {
                       for(CMXVenue* venue in venues) {
                           [networks addObjectsFromArray:venue.preferredNetworks];
                       }
                   } failure:^(NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }];
    
    [self registerForNetworks:networks
                   completion:^{
                       if (completion) {
                           completion();
                       }
                   } failure:^(NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) registerForNetworks:(NSArray*)networks
                 completion:(void (^)())completion
                    failure:(FailureBlock)failure {

    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    
    // Add APN id only if available
    NSString* deviceToken = [self deviceToken];
    if(deviceToken) {
        [params setObject:deviceToken forKey:@"pushNotificationRegistrationId"];
    }

    if (IS_IOS_7_OR_LATER) { // iOS 7+
        NSString* ipAddress = [self wiFiIPAddress];
        NSString* apMacAddress = [self accessPointMacAddress:networks];

        if(ipAddress && apMacAddress) {
            [params setObject:ipAddress forKey:@"clientIPAddress"];
            [params setObject:apMacAddress forKey:@"apMACAddress"];
            [params setObject:@"ios" forKey:@"clientType"];
        }
        else {
            if (failure) {
                // TODO
                /*
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                                           };
                failure([NSError errorWithDomain:NSHipsterErrorDomain code:-57 userInfo:userInfo]);
                 */
                failure(nil);
                return;
            }
        }
    }
    else {    // iOS 6
        NSString* macAddress = [self macAddress];
        [params setObject:macAddress forKey:@"clientMACAddress"];
        [params setObject:@"ios6" forKey:@"clientType"];
    }

	NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"POST" path:[self getRegisteringURL] parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    operation.SSLPinningMode = _httpsConnectionManager.defaultSSLPinningMode;
    operation.allowsInvalidSSLCertificate = _httpsConnectionManager.allowsInvalidSSLCertificate;

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        // Extract & store the device ID if available
        NSDictionary* headers = operation.response.allHeaderFields;
        NSString* location = [headers objectForKey:@"Location"];
        NSString* deviceId = nil;
        if(location) {
            deviceId = [[location componentsSeparatedByString:@"/"] lastObject];
        }

        [self saveCookies];

        if(deviceId) {
            [self storeDeviceId:deviceId];

            if (completion) {
                completion();
            }
        }
        else {
            // TODO
            failure(nil);
        }


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure) {
            failure(error);
        }
    }];

    [_httpsConnectionManager enqueueHTTPRequestOperation:operation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isRegisteredForRemoteNotifications {
#if !(TARGET_IPHONE_SIMULATOR)
    return [self deviceToken] != nil;
#else 
    return YES;
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) registerForRemoteNotifications {
	// Let the device know we want to receive push notifications
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#else
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) unregisterForRemoteNotifications {
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) registerDeviceToken:(NSData*)deviceToken {
    NSString* token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];

    // Store registration ID
    [self storeDeviceToken:token];
}


// returns the enabled types, also taking into account any systemwide settings; doesn't relate to connectivity
////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) areRemoteNotificationsEnabled {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
-(void)registerDeviceToken:(NSData*)deviceToken completion:(void (^)(BOOL))completion failure:(FailureBlock)failure {

    if([self isRegistered]) return;
    
    NSString* token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    
    // Store registration ID
    [self storeDeviceToken:token];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:token forKey:@"pushNotificationRegistrationId"];
    [params setObject:@"ios" forKey:@"clientType"];
    
    if (IS_IOS_7_OR_LATER) { // iOS 7 & earlier
        NSString* macAddress = [self macAddress];
        NSString* ipAddress = [self ipAddress];
        NSString* apMacAddress = [self accessPointMacAddress];
        
        [params setObject:macAddress forKey:@"clientMACAddress"];
        [params setObject:ipAddress forKey:@"clientIPAddress"];
        [params setObject:apMacAddress forKey:@"apMACAddress"];
        
    } else {    // iOS 5 && iOS 6
        NSString* macAddress = [self macAddress];
        NSString* ipAddress = [self ipAddress];
        NSString* apMacAddress = [self accessPointMacAddress];

        [params setObject:macAddress forKey:@"clientMACAddress"];
        [params setObject:ipAddress forKey:@"clientIPAddress"];
        [params setObject:apMacAddress forKey:@"apMACAddress"];
    }
    
	NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"POST" path:[self getRegisteringURL] parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    operation.SSLPinningMode = _httpsConnectionManager.defaultSSLPinningMode;
    operation.allowsInvalidSSLCertificate = _httpsConnectionManager.allowsInvalidSSLCertificate;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        BOOL registeredForGeolocation = false;
        
        // Extract & store the device ID if available
        NSDictionary* headers = operation.response.allHeaderFields;
        NSString* location = [headers objectForKey:@"Location"];
        if(location) {
            NSString* deviceId = [[location componentsSeparatedByString:@"/"] lastObject];
            [self storeDeviceId:deviceId];
            registeredForGeolocation = true;
        }

        [self saveCookies];
        
        if (completion) {
            completion(registeredForGeolocation);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
    
    [_httpsConnectionManager enqueueHTTPRequestOperation:operation];
}
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state {
    if([notification valueForKeyPath:@"aps.alert"]) {
        NSString* alert = [notification valueForKeyPath:@"aps.alert"];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CMX Notification Alert Title", @"")  message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadUserLocationWithCompletion:(void (^) (CMXClientLocation *clientLocation))completion
                              failure:(FailureBlock)failure {
    
    [_httpsConnectionManager getPath:[self getClientLocationURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CMXClientLocation *clientLocation = [[CMXClientLocation alloc] initWithDictionary:responseObject];
        self.clientLocation = clientLocation;
        
        if(completion) {
            completion(clientLocation);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)startUserLocationPollingWithInterval:(NSUInteger)interval update:(void (^) (CMXClientLocation *clientLocation))update {
    if(_clientLocationRequestTimer) {
        [_clientLocationRequestTimer invalidate];
    }

    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[update copy], @"completion", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.clientLocationRequestTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                                           target:self
                                                                         selector:@selector(updateUserLocation)
                                                                         userInfo:userInfo
                                                                          repeats:YES];
        [_clientLocationRequestTimer fire];
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)stopUserLocationPolling {
    if(_clientLocationRequestTimer) {
        [_clientLocationRequestTimer invalidate];
        self.clientLocationRequestTimer = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)postLocationFeedback:(CGPoint)location
                      start:(StartBlock)start
                 completion:(void (^) (void))completion
                    failure:(FailureBlock)failure {

    if (start) {
        start();
    }

    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%g", location.x] forKey:@"x"];
    [params setObject:[NSString stringWithFormat:@"%g", location.y] forKey:@"y"];

	NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"POST" path:[self getLocationFeedbackURL] parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    // Set acceptable content type
    [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", nil]];

    operation.SSLPinningMode = _httpsConnectionManager.defaultSSLPinningMode;
    operation.allowsInvalidSSLCertificate = _httpsConnectionManager.allowsInvalidSSLCertificate;

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (completion) {
            completion();
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure) {
            failure(error);
        }
    }];

    [_httpsConnectionManager enqueueHTTPRequestOperation:operation];

}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)internalLoadVenues:(NSString*)url
                    start:(StartBlock)start
               completion:(void (^)(NSArray *))completion
                  failure:(FailureBlock)failure {
    
    if (start) {
        start();
    }
    
    
    [_httpsConnectionManager getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //loading all the venues - the responseObject is an Array
        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray* venuesArray = (NSArray*)responseObject;
            NSMutableArray* venues = [NSMutableArray arrayWithCapacity:venuesArray.count];
            for(NSDictionary* venueDict in venuesArray) {
                if([venueDict isKindOfClass:[NSDictionary class]]) {
                    CMXVenue* venue = [[CMXVenue alloc] initWithDictionary:venueDict];
                    [venues addObject:venue];
                }
            }
            if (completion) {
                completion([venues copy]);
            }
        }
        //loading a single venue - responseobject is a dictionary
        else if([responseObject isKindOfClass:[NSDictionary class]]){
            NSMutableArray *venues = [[NSMutableArray alloc]init];
            CMXVenue* venue = [[CMXVenue alloc] initWithDictionary:responseObject];
            [venues addObject:venue];
            if (completion) {
                completion([venues copy]);
            }
        }else{
            if (failure) {
                // TODO invalid data error
                failure(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadVenuesWithStart:(StartBlock)start
                completion:(void (^)(NSArray *))completion
                   failure:(FailureBlock)failure{
    [self internalLoadVenues:[self getVenuesInfosURL] start:start completion:completion failure:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadVenue:(NSString*)venueId
           start:(StartBlock)start
      completion:(void (^) (CMXVenue* venue))completion
         failure:(FailureBlock)failure {
    [self internalLoadVenues:[self getVenueInfosURL:venueId]
                       start:start
                  completion:^(NSArray* venues) {
                      completion([venues objectAtIndex:0]);
                  }
                     failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadImageOfVenue:(NSString *)venueId start:(StartBlock)start completion:(void (^)(UIImage *))completion failure:(FailureBlock)failure{
  
    NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"GET" path:[self getImageURLForVenue:venueId] parameters:nil];
    
    [self downloadImageWithRequest:request start:start completion:completion failure:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadFloorsOfVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^) (NSArray *))completion
               failure:(FailureBlock)failure {
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:[self getFloorsURLOfVenue:venueId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray* floorsArray = (NSArray*)responseObject;
            NSMutableArray* floors = [NSMutableArray arrayWithCapacity:floorsArray.count];
            for(NSDictionary* floorDict in floorsArray) {
                if([floorDict isKindOfClass:[NSDictionary class]]) {
                    [floors addObject:[[CMXFloor alloc] initWithDictionary:floorDict]];
                }
            }
            if (completion) {
                completion([floors copy]);
            }
        }
        else {
            if (failure) {
                // TODO invalid data error
                failure(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadFloor:(NSString*)floorId
         ofVenue:(NSString*)venueId
           start:(StartBlock)start
      completion:(void (^) (CMXFloor *floor))completion
         failure:(FailureBlock)failure {
   
    if (start) {
        start();
    }
    
    NSString *floorURL = [self getFloorURLForFloor:floorId ofVenue:venueId];
    
    [_httpsConnectionManager getPath:floorURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 CMXFloor *floor = [[CMXFloor alloc] initWithDictionary:responseObject];
                                 
                                 if (completion) {
                                     completion(floor);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadImageOfFloor:(NSString*)floorId
                ofVenue:(NSString*)venueId
                  start:(StartBlock)start
             completion:(void (^) (UIImage *image))completion
                failure:(FailureBlock)failure {
    
    NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"GET" path:[self getImageURLForFloor:floorId ofVenue:venueId] parameters:nil];

    [self downloadImageWithRequest:request start:start completion:completion failure:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadPoisOfVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^)(NSArray *pois))completion
               failure:(FailureBlock)failure {
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:[self getPoisURLForVenue:venueId] parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 if([responseObject isKindOfClass:[NSArray class]]) {
                                     NSArray* poisArray = (NSArray*)responseObject;
                                     NSMutableArray* pois = [NSMutableArray arrayWithCapacity:poisArray.count];
                                     
                                     for(NSDictionary* poiDict in poisArray) {
                                         if([poiDict isKindOfClass:[NSDictionary class]]) {
                                             
                                             CMXPoi* poi = [[CMXPoi alloc] initWithDictionary:poiDict];
                                             if (![poi.imageType isEqualToString:@"none"]) {
                                                 [pois addObject:poi];
                                             }
                                             
                                         }
                                     }
                                     if (completion) {
                                         completion([pois copy]);
                                     }
                                 }
                                 else {
                                     if (failure) {
                                         // TODO invalid data error
                                         failure(nil);
                                     }
                                 }
                                 
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadPoisOfFloor:(NSString*)floorId
               ofVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^)(NSArray *pois))completion
               failure:(FailureBlock)failure {
    
    NSString *POIsURL = [self getPoisURLForFloor:floorId ofVenue:venueId];
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:POIsURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 NSArray *poiArray = [NSArray arrayWithObject:responseObject];
                                 NSArray *iterablePoiArray = [poiArray objectAtIndex:0];
                                 
                                 NSMutableArray *formatedPoiToReturn = [[NSMutableArray alloc] initWithCapacity:iterablePoiArray.count];
                                 
                                 
                                 for (NSInteger i=0; i<iterablePoiArray.count; i++) {
                                     
                                     CMXPoi *poi = [[CMXPoi alloc] initWithDictionary:[iterablePoiArray objectAtIndex:i]];
                                     
                                     if (![poi.imageType isEqualToString:@"none"]) {
                                        [formatedPoiToReturn addObject:poi];
                                     }

                                 }
                                 
                                 if (completion) {
                                     completion([formatedPoiToReturn copy]);
                                 }
                                 
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if (failure) {
                                     failure(error);
                                 }

                             }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadImageOfPoi:(NSString*)poiId
              ofVenue:(NSString*)venueId
                start:(StartBlock)start
           completion:(void (^)(UIImage *poiImage))completion
              failure:(FailureBlock)failure{
    
    NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"GET" path:[self getPoiImageURLForPoi:poiId ofVenue:venueId] parameters:nil];
    
    [self downloadImageWithRequest:request start:start completion:completion failure:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadPathForPoi:(NSString *)poiId
                start:(StartBlock)start
           completion:(void (^)(CMXPath *path))completion
              failure:(FailureBlock)failure {
    
    NSString *pathURL = [self getPathURLForPoi:poiId];
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:pathURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 NSArray *navigationArray = [NSArray arrayWithObject:responseObject];
                                 
                                 NSArray *iterableNavigationArray = [navigationArray objectAtIndex:0];
                                 
                                 NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:iterableNavigationArray.count];
                                 
                                 for (NSUInteger i=0; i< iterableNavigationArray.count; i++) {
                                     CMXPoint *point = [[CMXPoint alloc] initWithDictionary:[iterableNavigationArray objectAtIndex:i]];
                                     [points addObject:point];
                                 }
                                 
                                 CMXPath *pathModel = [[CMXPath alloc] initWithPoints:points];

                                 if (completion) {
                                     completion(pathModel);
                                 }
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if (failure) {
                                     failure(error);
                                 }
                             }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadQueryForKeywords:(NSString*)keywords
                    ofFloor:(NSString*)floorID
                    fromVenue:(NSString*)venueId
                      start:(StartBlock)start
                 completion:(void (^)(NSMutableArray *pois))completion
                    failure:(FailureBlock)failure {
    
    NSString *searchURL = [self getSearchURLForKeywords:keywords ofVenue:venueId];
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:searchURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 
                                 NSArray *poiArray = [NSArray arrayWithObject:responseObject];
                                 NSArray *iterablePoiArray = [poiArray objectAtIndex:0];
                                 
                                 NSMutableArray *formatedPoiToReturn = [[NSMutableArray alloc] initWithCapacity:iterablePoiArray.count];
                                 
                                 
                                 for (NSInteger i=0; i<iterablePoiArray.count; i++) {
                                     
                                     CMXPoi *poi = [[CMXPoi alloc] initWithDictionary:[iterablePoiArray objectAtIndex:i]];
                                     
                                     if (![poi.imageType isEqualToString:@"none"] && [poi.floorId isEqualToString:floorID]) {
                                         [formatedPoiToReturn addObject:poi];
                                     }
                                     
                                 }
                                 
                                 if (completion) {
                                     completion([formatedPoiToReturn copy]);
                                 }
                                 
                                 
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
}



////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadQueryForKeywords:(NSString*)keywords
                    ofVenue:(NSString*)venueId
                      start:(StartBlock)start
                 completion:(void (^)(NSMutableArray *pois))completion
                    failure:(FailureBlock)failure {
    
    NSString *searchURL = [self getSearchURLForKeywords:keywords ofVenue:venueId];
    
    if (start) {
        start();
    }

    [_httpsConnectionManager getPath:searchURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 
                                 NSArray *poiArray = [NSArray arrayWithObject:responseObject];
                                 NSArray *iterablePoiArray = [poiArray objectAtIndex:0];
                                 
                                 NSMutableArray *formatedPoiToReturn = [[NSMutableArray alloc] initWithCapacity:iterablePoiArray.count];
                                 
                                 
                                 for (NSInteger i=0; i<iterablePoiArray.count; i++) {
                                     
                                     CMXPoi *poi = [[CMXPoi alloc] initWithDictionary:[iterablePoiArray objectAtIndex:i]];
                                     if (![poi.imageType isEqualToString:@"none"]) {
                                         [formatedPoiToReturn addObject:poi];
                                     }
                                     
                                 }
                                 
                                 if (completion) {
                                     completion([formatedPoiToReturn copy]);
                                 }

                        
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadBannersForZone:(NSString *)zoneId
                  ofVenue:(NSString *)venueId
                    floor:(NSString *)floorId
                     start:(StartBlock)start
                completion:(void (^)(NSArray *))completion
                   failure:(FailureBlock)failure{
    
    if (start) {
        start();
    }
    
        [_httpsConnectionManager getPath:[self getBannersURLForZone:zoneId ofVenue:venueId floor:floorId]
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                                 if([responseObject isKindOfClass:[NSArray class]]) {
                                     
                                     NSMutableArray *banners = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)responseObject count]];
                                     
                                     for (NSDictionary* bannerInfo in (NSArray*)responseObject) {
                                         [banners addObject:[[CMXBanner alloc] initWithDictionary:bannerInfo]];
                                     }
                                     
                                     if (completion) {
                                         completion(banners);
                                     }
                                 }
                                 else {
                                     if (failure) {
                                         // TODO invalid data error
                                         failure(nil);
                                     }
                                 }
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadBannerImageForImage:(NSString*)imageId
                       ofVenue:(NSString*)venueId
                         floor:(NSString *)floorId
                          zone:(NSString*)zoneId
                    start:(StartBlock)start
               completion:(void (^)(UIImage *))completion
                  failure:(FailureBlock)failure {
    
    NSURLRequest *request = [_httpsConnectionManager requestWithMethod:@"GET" path:[self getBannerImageURLForImage:imageId ofVenue:venueId floor:floorId zone:zoneId] parameters:nil];
    
    [self downloadImageWithRequest:request start:start completion:completion failure:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadBleBeaconsOfVenue:(NSString*)venueId
                       start:(StartBlock)start
                  completion:(void (^)(NSArray *bleBeacons))completion
                     failure:(FailureBlock)failure {
    
    NSString *bleBeaconsVenueURL = [self getBleBeaconURLForVenue:venueId];
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:bleBeaconsVenueURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 if([responseObject isKindOfClass:[NSArray class]]) {
                                     
                                     NSMutableArray *blebeacons = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)responseObject count]];
                                     
                                     for (NSDictionary* bleBeacon in (NSArray*)responseObject) {
                                         [blebeacons addObject:[[CMXBleBeacon alloc] initWithDictionary:bleBeacon]];
                                     }
                                     
                                     if (completion) {
                                         completion(blebeacons);
                                     }
                                 }
                                 else {
                                     if (failure) {
                                         // TODO invalid data error
                                         failure(nil);
                                     }
                                 }
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadBleBeaconsOfFloor:(NSString*)floorId
                     ofVenue:(NSString*)venueId
                       start:(StartBlock)start
                  completion:(void (^)(NSArray *bleBeacons))completion
                     failure:(FailureBlock)failure {
    
    NSString *bleBeaconsURL = [self getBleBeaconURLForFloor:floorId ofVenue:venueId];
    
    if (start) {
        start();
    }
    
    [_httpsConnectionManager getPath:bleBeaconsURL
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 
                                 if([responseObject isKindOfClass:[NSArray class]]) {
                                     
                                     NSMutableArray *blebeacons = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)responseObject count]];
                                     
                                     for (NSDictionary* bleBeacon in (NSArray*)responseObject) {
                                         [blebeacons addObject:[[CMXBleBeacon alloc] initWithDictionary:bleBeacon]];
                                     }
                                     
                                     if (completion) {
                                         completion(blebeacons);
                                     }
                                 }
                                 else {
                                     if (failure) {
                                         // TODO invalid data error
                                         failure(nil);
                                     }
                                 }
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 if (failure) {
                                     failure(error);
                                 }
                                 
                             }];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark URL creation
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getVenuesInfosURL {
    NSURL *url = [NSURL URLWithString:VENUES_URL];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getVenueInfosURL:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:VENUE_URL, venueId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getImageURLForVenue:(NSString*)venueID {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:VENUE_DOWNLOAD, venueID]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getRegisteringURL  {
    NSURL *url = [NSURL URLWithString:CLIENT_REGISTERING_URL];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getLocationFeedbackURL  {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CLIENT_LOCATION_FEEDBACK_URL, [self deviceId]]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getClientLocationURL {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CLIENTS_LOCATION_URL, [self deviceId]]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getFloorsURLOfVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MAPS_INFO_URL, venueId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getFloorURLForFloor:(NSString*)floorId ofVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FLOOR_INFO_URL, venueId, floorId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getImageURLForFloor:(NSString*)floorId ofVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FLOOR_IMAGE_URL, venueId, floorId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)getPoiImageURLForPoi:(NSString*)poiId ofVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:POIS_IMAGE_URL, venueId, poiId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getPoisURLForVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:POIS_URL, venueId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getPoisURLForFloor:(NSString*)floorId ofVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FLOOR_POIS_URL, venueId, floorId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getBleBeaconURLForFloor:(NSString*)floorId ofVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:BLEBEACON_URL, venueId, floorId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getBleBeaconURLForVenue:(NSString*)venueId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:BLEBEACON_VENUE_URL, venueId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getSearchURLForKeywords:(NSString*)keywords ofVenue:(NSString*)venueId {
    NSURL *url =  [NSURL URLWithString:[NSString stringWithFormat:SEARCH_URL, venueId, [keywords urlEncodedString]]];
    CMXLog(@"URL %@", url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getPathURLForPoi:(NSString*)poiId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:PATH_URL, [self deviceId], poiId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getBannersURLForZone:(NSString*)zoneId ofVenue:(NSString*)venueId floor:(NSString*)floorId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:BANNERS_INFO_URL, venueId, floorId, zoneId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getBannerImageURLForImage:(NSString*)imageId ofVenue:(NSString*)venueId floor:(NSString*)floorId zone:(NSString*)zoneId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:BANNER_IMAGE_URL, venueId, floorId, zoneId, imageId]];
    CMXLog(@"URL %@",url.absoluteString);
    return [url absoluteString];
}

#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setConfiguration:(CMXClientConfiguration *)configuration {
    _configuration = [configuration copy];
    
    self.httpsConnectionManager = [[AFHTTPClient alloc] initWithBaseURL:_configuration.serverURL];
    
    // Customize connection manager
    [_httpsConnectionManager registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [_httpsConnectionManager setDefaultHeader:@"Accept" value:@"application/json"];
    
    [_httpsConnectionManager setParameterEncoding:AFFormURLParameterEncoding];
    [_httpsConnectionManager setAllowsInvalidSSLCertificate:TRUE];
    
    // Enable network activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updateUserLocation {
    
    NSDictionary* userInfo = _clientLocationRequestTimer.userInfo;
    void (^completion)(CMXClientLocation *clientLocation) = [userInfo objectForKey:@"completion"];
    void(^failure)(NSError*) = [userInfo objectForKey:@"failure"];
    
    [self loadUserLocationWithCompletion:completion failure:failure];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)downloadImageWithRequest:(NSURLRequest*)request
                          start:(StartBlock)start
                     completion:(void (^) (UIImage *image))completion
                        failure:(FailureBlock)failure{
    
    if (start) {
        start();
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // Set acceptable content type
    [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:
                                                               @"image/gif",
                                                               @"image/png",
                                                               @"image/svg+xml",
                                                               @"image/jpeg",
                                                               @"image/jpg",
                                                               nil]];

    operation.allowsInvalidSSLCertificate = TRUE;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSHTTPURLResponse *response = operation.response;
        NSString *contentType = [[response allHeaderFields] valueForKey:@"content-type"];

        if (completion) {
            NSData *tmpData = [[NSData alloc] initWithData:responseObject];
            
            if (tmpData != nil) {
                
                if ([contentType isEqualToString:@"image/svg+xml"]) {
                    
                    // create uiimage from svg data
                    [self createSVGFromData:tmpData completion:completion failure:failure];
                    
                }else{
                    UIImage *image = [UIImage imageWithData:tmpData];
                    if (image) {
                        completion(image);
                    }else{
                        if (failure) {
                            failure([NSError errorWithDomain:@"Error when creating uiimage from downloaded data" code:0 userInfo:nil]);
                        }

                    }
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
    
    
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    // Set the max number of concurrent operations (threads)
    [_operationQueue addOperation:operation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)createSVGFromData:(NSData*)svgData
              completion:(void (^) (UIImage *image))completion
                 failure:(FailureBlock)failure{
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // remote server's svg
    
    if (_svgToUImage == nil) {
        _svgToUImage = [[SvgToUIImage alloc] init];
    }
    
    completion([_svgToUImage svgData:svgData]);
    /*
    [_svgToUImage loadSVGData:svgData onComplete:^(UIImage *image) {
        
        //NSLog(@"UIImage new size %@",NSStringFromCGSize(image.size));
       
            //   dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
            //   });
        

    } onFailure:^(NSError *error) {
        if (failure) {
            //       dispatch_async(dispatch_get_main_queue(), ^{
            failure([NSError errorWithDomain:@"Error when parsing SVG" code:0 userInfo:nil]);
            //       });
        }
    }];
        // Convert to uiimage representation
    // });
     */
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// Called by Reachability whenever status changes
- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);

    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            break;
        }
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            break;
        }
    }
    CMXLog(@"Network status changed : %@", statusString);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isConnected {
    NetworkStatus netStatus = [_internetReach currentReachabilityStatus];
    return netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isConnectedToVenueWifi:(NSArray*)networks {
    NetworkStatus netStatus = [_internetReach currentReachabilityStatus];
    if(netStatus == ReachableViaWiFi) {
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *ifnam in ifs) {
            NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (info[@"SSID"]) {
                NSString* ssid = info[@"SSID"];
                for(CMXNetwork* network in networks) {
                    if([ssid isEqualToString:network.ssid]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) storeDeviceToken:(NSString*)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) deviceToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) storeDeviceId:(NSString*)deviceId {
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:DEVICE_ID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) deviceId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_ID_KEY];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) macAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        CMXLog(@"Mac Address: %@", macAddressString);
        
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    // Error...
    CMXLog(@"Error: %@", errorFlag);
    
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) accessPointMacAddress:(NSArray*)networks {
#if !(TARGET_IPHONE_SIMULATOR)
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            NSString* ssid = info[@"SSID"];
            NSMutableArray *preferredSsidSet = [[NSMutableArray alloc]init];
            for(CMXNetwork* network in networks) {
                [preferredSsidSet addObject:network.ssid];
                if([ssid isEqualToString:network.ssid]) {
                    return [info objectForKey:@"BSSID"];
                }
            }
            //No preferred network set. But the device is connected to wifi. Send back its present ssid.
            if (!preferredSsidSet || !preferredSsidSet.count){
                
                return [info objectForKey:@"BSSID"];
                
            }else{
                //No ssid match found. Preferred ssid is not there.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:[NSString stringWithFormat:@"%@%@%@%@",@"Connected to ssid :",ssid,@". Need to connect to SSIDs:",preferredSsidSet]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                return [info objectForKey:@"BSSID"];
            }
            
            
        }
    }
    //No Wifi ssid found.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"No WiFi SSID connection discovered"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    return nil;
#else
    // ifs is not available for simulator, returns a fake BSSID;
    return @"ca:fe:ca:fe:ca:fe";
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) wiFiIPAddress {
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;

        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);

        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;

            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
#if !(TARGET_IPHONE_SIMULATOR)
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
#else
                    if([[NSString stringWithUTF8String:Temp->ifa_name] hasPrefix:@"en"])
#endif
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }

                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }

        // Free the memory of the interfaces
        freeifaddrs(Interfaces);

        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }

        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)saveCookies {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if(cookies) {
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: cookiesData forKey:@"cookies"];
        [defaults synchronize];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadCookies {
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookies"];
    if(data) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookies){
            [cookieStorage setCookie: cookie];
        }
    }
}

@end
