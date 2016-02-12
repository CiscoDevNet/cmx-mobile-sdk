//
//  CMXBannerViewController.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Controller that manages banners
 */
@interface CMXBannerViewController : UIViewController<UIGestureRecognizerDelegate>

/**
 *  Image view that displays banners.
 */
@property (nonatomic,strong) IBOutlet UIImageView *imageView;

/**
 *  Set banner images to display.
 *
 *  @param images   Array of UIImage representing the banners.
 *  @param duration Duration in seconds of each image.
 */
-(void) setBannerImages:(NSArray*)images imageDuration:(CGFloat)duration;

@end
