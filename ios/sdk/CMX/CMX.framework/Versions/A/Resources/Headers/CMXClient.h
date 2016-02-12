//
//  CMXClient.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class UIImage;
@class CMXClientConfiguration;
@class CMXClientLocation;
@class CMXFloor;
@class CMXPath;
@class CMXPoi;
@class CMXVenue;
@class CMXBanner;

// Blocks definitions
typedef void(^StartBlock)();
typedef void(^FailureBlock)(NSError*);


/**
 *  Client that manages data loading & network connexions with CMX server.
 */
@interface CMXClient : NSObject

/**
*  The client configuration.
*/
@property (nonatomic, copy) CMXClientConfiguration *configuration;

/**
 *  Latest indoor client location.
 */
@property (nonatomic, strong, readonly) CMXClientLocation* clientLocation;


/**
 *  Return the shared instance of the CMX client.
 *
 *  @return The shared instance of the CMX client.
 */
+(CMXClient*) instance;

/**
 *  Return boolean indicating if client has been registered to receive geolocation data.
 *
 *  @return YES if client has already been registered, NO otherwise.
 */
-(BOOL) isRegistered;

/**
 *  Register the device to given servers to receive geolocation data.
 *
 *  @param networks   A list of networks.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and no argument.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 *  @note With iOS 7 or earlier, device must be connected to one of the given networks to register. Otherwise, registeration will fail.
 */
-(void) registerForNetworks:(NSArray*)networks
                 completion:(void (^)())completion
                    failure:(FailureBlock)failure;

/**
 *  Return boolean indicating if client has already been registered to receive remote notifications or not.
 *
 *  @return YES if client has already been registered to receive remote notifications, NO otherwise.
 */
-(BOOL) isRegisteredForRemoteNotifications;

/**
 *  Register the app for remote notifications.
 */
-(void) registerForRemoteNotifications;

/**
 *  Unregister the app for remote notifications.
 */
-(void) unregisterForRemoteNotifications;

/**
 *  Register the device token used to receive push notification.
 *
 *  @param deviceToken The token that identifies the device to APS, got from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 */
-(void) registerDeviceToken:(NSData*)deviceToken;

/**
 *  Register the device to CMX server to receive push notification. Must be called in application:didRegisterForRemoteNotificationsWithDeviceToken: of your appplication delegate.
 *
 *  @param deviceToken The token that identifies the device to APS, got from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 *  @param completion  A block object to be executed when the request operation finishes successfully. This block has no return value and no argument.
 *  @param failure     A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
/*
-(void)registerDeviceToken:(NSData*)deviceToken
                completion:(void (^) (BOOL registeredForGeolocation))completion
                   failure:(FailureBlock)failure;
*/

/**
 *  Handle incoming push notifications.
 *
 *  @param notification The notification payload, as passed to your application delegate.
 *  @param state        The application state at the time the notification was received.
 */
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state;

/**
 *  Load user location.
 *
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument : the user location.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadUserLocationWithCompletion:(void (^) (CMXClientLocation *clientLocation))completion
                              failure:(FailureBlock)failure;

/**
 *  Start indoor user location.
 *
 *  @param interval Interval in seconds between updates.
 *  @param update   A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument : the user location.
 *  @note Device must be registered to use this method.
 */
-(void)startUserLocationPollingWithInterval:(NSUInteger)interval update:(void (^) (CMXClientLocation *clientLocation))update;

/**
 *  Stop indoor user location.
 */
-(void)stopUserLocationPolling;


/**
 *  Post location feedback.
 *
 *  @param location   location of the user (X, Y in image space)
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)postLocationFeedback:(CGPoint)location
                      start:(StartBlock)start
                 completion:(void (^) (void))completion
                    failure:(FailureBlock)failure;


/**
 *  Get informations about all venues.
 *
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of venues created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadVenuesWithStart:(StartBlock)start
              completion:(void (^) (NSArray *venues))completion
                 failure:(FailureBlock)failure;

/**
 *  Load informations for a given venue.
 *
 *  @param venueId    Id of the venue to load.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the venue created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadVenue:(NSString*)venueId
           start:(StartBlock)start
      completion:(void (^) (CMXVenue *venue))completion
         failure:(FailureBlock)failure;

/**
 *  Load image of the given venue.
 *
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the image created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadImageOfVenue:(NSString*)venueId
                    start:(StartBlock)start
             completion:(void (^) (UIImage *image))completion
                failure:(FailureBlock)failure;

/**
 *  Load all floors for a given venue.
 *
 *  @param venueId    id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of floors created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadFloorsOfVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^) (NSArray *floors))completion
               failure:(FailureBlock)failure;

/**
 *  Load floor.
 *
 *  @param floorId    Id of the floor.
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the floor created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadFloor:(NSString*)floorId
         ofVenue:(NSString*)venueId
           start:(StartBlock)start
      completion:(void (^) (CMXFloor *floor))completion
         failure:(FailureBlock)failure;

/**
 *  Load image of the given floor.
 *
 *  @param floorId    Id of the floor.
 *  @param venueId    Id of the venue
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the image created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadImageOfFloor:(NSString*)floorId
                ofVenue:(NSString*)venueId
                  start:(StartBlock)start
             completion:(void (^) (UIImage *image))completion
                failure:(FailureBlock)failure;

/**
 *  Load all pois of the venue.
 *
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of pois created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadPoisOfVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^)(NSArray *pois))completion
               failure:(FailureBlock)failure;

/**
 *  Load pois for a given floor.
 *
 *  @param floorId    Id of the floor.
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of pois created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadPoisOfFloor:(NSString*)floorId
               ofVenue:(NSString*)venueId
                 start:(StartBlock)start
            completion:(void (^)(NSArray *pois))completion
               failure:(FailureBlock)failure;

/**
 *  Load image for a given poi.
 *
 *  @param poiId      Id of the poi.
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the image of pois created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadImageOfPoi:(NSString*)poiId
              ofVenue:(NSString*)venueId
                start:(StartBlock)start
           completion:(void (^)(UIImage *poiImage))completion
              failure:(FailureBlock)failure;

/**
 *  Load path for a given poi.
 *
 *  @param poiId      Id of the poi.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the path object created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadPathForPoi:(NSString *)poiId
                start:(StartBlock)start
           completion:(void (^)(CMXPath *path))completion
              failure:(FailureBlock)failure;

/**
 *  Search pois for given keywords.
 *
 *  @param keywords   keywords.
 *  @param venueId    Id of the venue.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of pois created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadQueryForKeywords:(NSString*)keywords
                    ofVenue:(NSString*)venueId
                       start:(StartBlock)start
                  completion:(void (^)(NSMutableArray *pois))completion
                     failure:(FailureBlock)failure;

/**
 *  Load all banners for a given zone.
 *
 *  @param zoneId     Id of the zone.
 *  @param venueId    Id of the venue.
 *  @param floorId    Od of the floor.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of CMXBanner objects created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadBannersForZone:(NSString *)zoneId
                  ofVenue:(NSString *)venueId
                    floor:(NSString *)floorId
                    start:(StartBlock)start
               completion:(void (^)(NSArray *))completion
                  failure:(FailureBlock)failure;

/**
 *  Load image for a given banner.
 *
 *  @param imageId    Id of the banner's image.
 *  @param venueId    Id of the banner's venue.
 *  @param floorId    Id of the banner's floor.
 *  @param zoneId     Id of the banner's zone.
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the image of banner created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadBannerImageForImage:(NSString*)imageId
                       ofVenue:(NSString*)venueId
                         floor:(NSString *)floorId
                          zone:(NSString*)zoneId
                         start:(StartBlock)start
                    completion:(void (^)(UIImage *))completion
                       failure:(FailureBlock)failure;
@end
