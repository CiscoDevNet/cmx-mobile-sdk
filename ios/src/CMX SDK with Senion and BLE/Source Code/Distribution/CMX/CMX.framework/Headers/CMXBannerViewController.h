//
//  CMXBannerViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @header CMXBannerViewController
 * This view controller serves the banner images with a specified duration for each image
 * @copyright Cisco Systems
 */

/*!
 * @class CMXBannerViewController
 * @abstract Controller that manages banners
 */
@interface CMXBannerViewController : UIViewController<UIGestureRecognizerDelegate>

/**
 *  @property imageView
 *              Image view that displays banners.
 */
@property (nonatomic,strong) IBOutlet UIImageView *imageView;

/**
 *  @abstract Set banner images to display.
 *
 *  @param images   Array of UIImage representing the banners.
 *  @param duration Duration in seconds of each image.
 */
-(void) setBannerImages:(NSArray*)images imageDuration:(CGFloat)duration;

@end
