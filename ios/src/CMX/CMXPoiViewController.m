//
//  CMXPoiDescriptionViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXPoiViewController.h"
#import "CMXPoi.h"
#import "CMXDebug.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "UIView+Toast.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXPoiViewController ()<UIActionSheetDelegate>

/**
 *  Current poi model
 **/
@property (nonatomic,strong) CMXPoi *model;

/**
 *  Poi image
 **/
@property (nonatomic,strong) UIImage *image;

/**
 *  Poi image
 **/
@property (nonatomic,strong) IBOutlet UIButton *shareBt;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXPoiViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithPoi:(CMXPoi*)poi image:(UIImage *)image {

    if(self = [super initWithNibName:nil bundle:nil]) {
        self.model = poi;
        self.image = image;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.poiTitleLabel.text = self.model.name;
    self.poiImageView.image = self.image;
    self.shareBt.hidden = ![self isCheckinAvailable];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction) checkinAction:(id)sender {

    NSString *actionSheetTitle = NSLocalizedString(@"CMX Check In Title", @""); //Action Sheet Title
    NSString *cancelTitle = NSLocalizedString(@"CMX Cancel Button", @"");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];

    if([self isFacebookCheckinAvailable]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CMX Facebook", @"")];
    }

    if([self isTwitterCheckinAvailable]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CMX Twitter", @"")];
    }

    [actionSheet showInView:self.view];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction) goToAction:(id)sender {
    if([_delegate respondsToSelector:@selector(poiViewController:didSelectTargetDestination:)]) {
        [_delegate poiViewController:self didSelectTargetDestination:_model.identifier];
    }
}

#pragma mark - UIActionSheetDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:NSLocalizedString(@"CMX Facebook", @"")]) {
        [self checkinFacebook];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"CMX Twitter", @"")]) {
        [self checkinTwitter];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isCheckinAvailable {
    return [self isFacebookCheckinAvailable] || [self isTwitterCheckinAvailable];
}

#pragma mark - Facebook
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isFacebookCheckinAvailable {
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    BOOL hasFBAppId = [infoDict objectForKey:@"FacebookAppID"] != nil;
    return _model.facebookPlaceId != nil && hasFBAppId;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) fbConnectWithCompletionHandler:(void (^)())completion {
    // if the session is open, then load the data for our view controller
    if (FBSession.activeSession.isOpen) {
        completion();
    }
    else {
        // Open session with basic_info (required) permissions
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             __block NSString *alertText;
             __block NSString *alertTitle;
             if (!error) {
                 // If the session was opened successfully
                 if (state == FBSessionStateOpen){
                     completion();
                 }
                 else {
                     // There was an error, handle it
                     if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
                         // Error requires people using an app to make an action outside of the app to recover
                         // The SDK will provide an error message that we have to show the user
                         alertTitle = @"Something went wrong";
                         alertText = [FBErrorUtility userMessageForError:error];
                         [[[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertText
                                                    delegate:self
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil] show];

                     }
                     else {
                         // If the user cancelled login
                         if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                             alertTitle = @"Login cancelled";
                             alertText = @"Your checkin will not be published because you didn't grant the permission.";
                             [[[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:alertText
                                                        delegate:self
                                               cancelButtonTitle:@"OK!"
                                               otherButtonTitles:nil] show];

                         }
                         else {
                             // For simplicity, for all other errors we show a generic message
                             // You can read more about how to handle other errors in our Handling errors guide
                             // https://developers.facebook.com/docs/ios/errors/
                             NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                                                                objectForKey:@"body"]
                                                               objectForKey:@"error"];
                             alertTitle = @"Something went wrong";
                             alertText = [NSString stringWithFormat:@"Please retry. \
                                          If the problem persists contact us and mention this error code: %@",
                                          [errorInformation objectForKey:@"message"]];
                             [[[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:alertText
                                                        delegate:self
                                               cancelButtonTitle:@"OK!"
                                               otherButtonTitles:nil] show];
                         }
                     }
                 }
             }
             else {
                 alertTitle = @"Something went wrong";
                 alertText = [FBErrorUtility userMessageForError:error];
                 [[[UIAlertView alloc] initWithTitle:alertTitle
                                             message:alertText
                                            delegate:self
                                   cancelButtonTitle:@"OK!"
                                   otherButtonTitles:nil] show];
             }
         }];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) fbCheckPermissionsWithCompletionHandler:(void (^)())completion {
    // Check for publish permissions
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *permissions= [(NSArray *)[result data] objectAtIndex:0];
                                  if (![permissions objectForKey:@"publish_actions"]){
                                      // Publish permissions not found, ask for publish_actions
                                      [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              __block NSString *alertText;
                                                                              __block NSString *alertTitle;
                                                                              if (!error) {
                                                                                  if ([FBSession.activeSession.permissions
                                                                                       indexOfObject:@"publish_actions"] == NSNotFound){
                                                                                      // Permission not granted, tell the user we will not publish
                                                                                      alertTitle = @"Permission not granted";
                                                                                      alertText = @"Your action will not be published to Facebook.";
                                                                                      [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                                                  message:alertText
                                                                                                                 delegate:self
                                                                                                        cancelButtonTitle:@"OK!"
                                                                                                        otherButtonTitles:nil] show];
                                                                                  } else {
                                                                                      // Permission granted, publish the OG story
                                                                                      completion();
                                                                                  }

                                                                              } else {
                                                                                  // There was an error, handle it
                                                                                  // See https://developers.facebook.com/docs/ios/errors/
                                                                              }
                                                                          }];

                                  } else {
                                      // Publish permissions found, publish the OG story
                                      completion();
                                  }

                              } else {
                                  // There was an error, handle it
                                  // See https://developers.facebook.com/docs/ios/errors/
                              }
                          }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) checkinFacebook {
    [self fbConnectWithCompletionHandler:^{
        [self fbCheckPermissionsWithCompletionHandler:^{

            NSString* placeId = _model.facebookPlaceId;

            FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
            params.place = placeId;
            BOOL canShare = [FBDialogs canPresentShareDialogWithParams:params];
            if (canShare) {
                // Present the share dialog
                [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {

//                     if (!error) {
//                     // Link posted successfully to Facebook
//                     NSLog([NSString stringWithFormat:@"result: %@", results]);
//                     } else {
//                     // An error occurred, we need to handle the error
//                     // See: https://developers.facebook.com/docs/ios/errors
//                     NSLog([NSString stringWithFormat:@"%@", error.description]);
//                     }
                }];
            } else {
                NSMutableDictionary *feedParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   placeId, @"place",
                                                   nil];
                // Present the feed dialog
                [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                       parameters:feedParams
                                                          handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                              if (error) {
                                                                  // An error occurred, we need to handle the error
                                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                                  //NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                              } else {

//                                                                   if (result == FBWebDialogResultDialogNotCompleted) {
//                                                                   // User cancelled.
//                                                                   NSLog(@"User cancelled.");
//                                                                   } else {
//                                                                   // Handle the publish feed callback
//                                                                   NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//
//                                                                   if (![urlParams valueForKey:@"post_id"]) {
//                                                                   // User cancelled.
//                                                                   NSLog(@"User cancelled.");
//
//                                                                   } else {
//                                                                   // User clicked the Share button
//                                                                   NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
//                                                                   NSLog(@"result %@", result);
//                                                                   }
//                                                                   }
                                                              }
                                                          }];
            }
        }];
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*) parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - Twitter
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isTwitterCheckinAvailable {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && _model.twitterPlaceId;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) checkinTwitter {

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error) {
                                      if (granted == YES)
                                      {
                                          NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

                                          if ([arrayOfAccounts count] > 0)
                                          {
                                              ACAccount *twitterAccount = [arrayOfAccounts lastObject];

                                              NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];

                                              NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                                              [parameters setObject:NSLocalizedString(@"CMX Check In Tweet", @"") forKey:@"status"];

                                              [parameters setObject:_model.twitterPlaceId forKey:@"place_id"];

                                              SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                          requestMethod:SLRequestMethodPOST
                                                                                                    URL:requestURL
                                                                                             parameters:parameters];

                                              postRequest.account = twitterAccount;

                                              [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                  if (responseData) {
                                                      NSInteger statusCode = urlResponse.statusCode;
                                                      if (statusCode >= 200 && statusCode < 300) {
                                                          // Check in published
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.view makeToast:NSLocalizedString(@"CMX Check In Succeeded", @"")];
                                                          });
                                                      }
                                                      else {
#if DEBUG
                                                          CMXLog(@"[ERROR] Server responded: status code %d %@", (int)statusCode,
                                                                [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                                                          NSDictionary *postResponseData =
                                                          [NSJSONSerialization JSONObjectWithData:responseData
                                                                                          options:NSJSONReadingMutableContainers
                                                                                            error:NULL];
                                                          CMXLog(@"[ERROR] Response %@", postResponseData);
#endif
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                                              message:[error localizedDescription]
                                                                                                             delegate:nil
                                                                                                    cancelButtonTitle:NSLocalizedString(@"CMX OK Button", @"")
                                                                                                    otherButtonTitles:nil];
                                                              [alert show];
                                                          });
                                                      }
                                                  }
                                                  else {
                                                      CMXLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
                                                  }
                                              }];
                                          }
                                      } else {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              // Handle failure to get account access
                                              UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                              message:NSLocalizedString(@"CMX Twitter No Access", @"")
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:NSLocalizedString(@"CMX OK Button", @"")
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                          });
                                      }
                                  }];

}

@end
