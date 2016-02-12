//
//  CMXClient.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SLIndoorLocation/SLIndoorLocation.h>


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

/*!
 * @header CMXClient 
 * Manages the network connection, registration , loading data including venues, floors, poi, banners , client location.
 * @copyright Cisco Systems
 */


/*!
 * @class CMXClient
 * @abstract Client that manages data loading & network connections with CMX server.
 * @discussion The application is recommended to have a single CMXClient instance.
 */
@interface CMXClient : NSObject<CLLocationManagerDelegate,SLIndoorLocationManagerDelegate>

/*!
*  @property configuration
*               The client configuration.Set the server url.
*/
@property (nonatomic, copy) CMXClientConfiguration *configuration;

/*!
 *  @property clientLocation
 *              Latest indoor client location.
 */
@property (nonatomic, strong, readonly) CMXClientLocation* clientLocation;


/*!
 *  Return the shared instance of the CMX client.
 *
 *  @return The shared instance of the CMX client.
 */
+(CMXClient*) instance;

/*!
 *  Return boolean indicating if client has been registered to receive geolocation data.
 *
 *  @return YES if client has already been registered, NO otherwise.
 */
-(BOOL) isRegistered;

/*!
 *@abstract Initialize and register the application with the cloud server
 *
 *@discussion As a part of this api we perform the following actions : 1. We get the push notifications devicetoken key from the APNS  2. We get the venues information from the cloud server 3. We parse the venue information to get the preferred networks on the venue 4. We register the device with the cloud server using the preferred networks information.
     The developer can use individual APIs for each of the above functions , all provided in this class
      This call will NOT execute succesfully if the user is not present at the venue or connected to an access point at the venue. Actions 1,2,3 (described above) will work successfully , action 4 will fail.
     If this call gets executed successfully, the developer needs to call the startLocationPollingWithIntervalupdate or loadUserLocationWithCompletionfailure method to get the user location depending on periodic update or one-time update respectively.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and no argument.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 *  @note With iOS 7 or earlier, device must be connected to one of the given networks to register. Otherwise, the registration step will fail.
 */
-(void) initWithRegistrationCompletion:(void (^)())completion
                               failure:(FailureBlock)failure;

/*!
 *  @abstract Register the device to given servers to receive geolocation data.
 *
 *  @param networks   A list of networks as a dictionary of ssid and password.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and no argument.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 *  @note With iOS 7 or earlier, device must be connected to one of the given networks to register. Otherwise, registration will fail.
 */
-(void) registerForNetworks:(NSArray*)networks
                 completion:(void (^)())completion
                    failure:(FailureBlock)failure;

/*!
 *  Return boolean indicating if client has already been registered to receive remote notifications or not.
 *
 *  @return YES if client has already been registered to receive remote notifications, NO otherwise.
 */
-(BOOL) isRegisteredForRemoteNotifications;

/*!
 *  @abstract Register the app for remote notifications.
 */
-(void) registerForRemoteNotifications;

/*!
 *  @abstract Unregister the app for remote notifications.
 */
-(void) unregisterForRemoteNotifications;

/*!
 *  @abstract Register the device token used to receive push notification.
 *
 *  @param deviceToken The token that identifies the device to APS, got from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 */
-(void) registerDeviceToken:(NSData*)deviceToken;


/*!
 *  @abstract Handle incoming push notifications.
 *
 *  @param notification The notification payload, as passed to your application delegate.
 *  @param state        The application state at the time the notification was received.
 */
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state;

/*!
 *  @abstract Load user location once at the present instant.
 *
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument : the user location.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadUserLocationWithCompletion:(void (^) (CMXClientLocation *clientLocation))completion
                              failure:(FailureBlock)failure;

- (double) loadUserHeading;

/*!
 *  @abstract Start indoor user location at certain intervals.
 *
 *  @param interval Interval in seconds between updates.
 *  @param update   A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument : the user location.
 *  @note Device must be registered to use this method.
 */
-(void)startUserLocationPollingWithInterval:(NSUInteger)interval update:(void (^) (CMXClientLocation *clientLocation))update;

/*!
 *  @abstract Stop indoor user location updates at intervals.
 */
-(void)stopUserLocationPolling;


/*!
 *  @abstract Post user location feedback to the server.
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

/*!
 *  @abstract Post user comment and rating to the server.
 *
 *  @param comment    The user comment string
 *  @param rating     The user rating as a string
 */

-(void)postFeedbackWithComment:(NSString*)comment
                     andRating:(NSString*) rating
                    completion:(void (^) (void))completion
                       failure:(FailureBlock)failure;


/*!
 *  @abstract Get informations about all venues.
 *
 *  @param start      A block object to be executed when the request operation starts. This block has no return value and takes no argument.
 *  @param completion A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the array of venues created from the response data of request.
 *  @param failure    A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
-(void)loadVenuesWithStart:(StartBlock)start
              completion:(void (^) (NSArray *venues))completion
                 failure:(FailureBlock)failure;

/*!
 *  @abstract Load informations for a given venue with a particular venue Id.
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

/*!
 *  @abstract Load image of the given venue with its venue Id.
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

/*!
 *  @abstract Load all floors for a given venue with a venue Id.
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

/*!
 *  @abstract Load floor information like dimension and name.
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

/*!
 *  @abstract Load image of the given floor.
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

/*!
 *  @abstract Load all pois of the venue.
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

/*!
 *  @abstract Load pois for a given floor.
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

/*!
 *  @abstract Load image for a given poi.
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

/*!
 *  @abstract Load path for a given poi.
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

/*!
 *  @abstract Search pois for given keywords.
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

/*!
 *  @abstract Load all banners for a given zone.
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

/*!
 *  @abstract Load image for a given banner.
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
