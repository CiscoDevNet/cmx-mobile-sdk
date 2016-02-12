//
//  CMXPoiDescriptionViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMXPoi;
@protocol CMXPoiViewControllerDelegate;

/*!
 * @header CMXPoiViewController
 * This view controller displays the poi image, title etc. and other poi informations
 * @copyright Cisco Systems
 */

/*!
 *  @class CMXPoiViewController
 *  @abstract Controller that displays information about a poi.
 */
@interface CMXPoiViewController : UIViewController

/*!
 *  @property delegate
 *              Controller delegate.
 */
@property (nonatomic, assign) id<CMXPoiViewControllerDelegate> delegate;

/*!
 *  @property poiImageView
 *              Poi logo
 **/
@property (nonatomic,strong) IBOutlet UIImageView *poiImageView;

/*!
 *  @property poiTitleLabel
 *              Poi name
 **/
@property (nonatomic,strong) IBOutlet UILabel *poiTitleLabel;

/*!
 *  @abstract Initialize the controller with given poi and it's image representation.
 *
 *  @param poi   A poi object
 *  @param image Poi's image
 *
 *  @return The instance of the controller.
 */
-(id) initWithPoi:(CMXPoi*)poi image:(UIImage *)image;

@end


/*!
 *  @protocol CMXPoiViewControllerDelegate Poi view controller delegate protocol.
 */
@protocol CMXPoiViewControllerDelegate<NSObject>

@optional

/*!
 *  @abstract Method called when user has selected this poi as target destination
 *
 *  @param controller Poi controller.
 *  @param poiId      Poi's id of the target destination.
 */
-(void) poiViewController:(CMXPoiViewController*)controller didSelectTargetDestination:(NSString*)poiId;

@end
