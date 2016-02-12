//
//  CMXPoiDescriptionViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMXPoi;
@protocol CMXPoiViewControllerDelegate;


/**
 *  Controller that displays information about a poi.
 */
@interface CMXPoiViewController : UIViewController

/**
 *  Controller delegate.
 */
@property (nonatomic, assign) id<CMXPoiViewControllerDelegate> delegate;

/**
 *  Poi logo
 **/
@property (nonatomic,strong) IBOutlet UIImageView *poiImageView;

/**
 *  Poi name
 **/
@property (nonatomic,strong) IBOutlet UILabel *poiTitleLabel;

/**
 *  Initialize the controller with given poi and his image representation.
 *
 *  @param poi   A poi object
 *  @param image Poi's image
 *
 *  @return The instance of the controller.
 */
-(id) initWithPoi:(CMXPoi*)poi image:(UIImage *)image;

@end


/**
 *  Poi view controller delegate protocol.
 */
@protocol CMXPoiViewControllerDelegate<NSObject>

@optional

/**
 *  Method called when user has selected this poi as target destination
 *
 *  @param controller Poi controller.
 *  @param poiId      Poi's id of the target destination.
 */
-(void) poiViewController:(CMXPoiViewController*)controller didSelectTargetDestination:(NSString*)poiId;

@end
