//
//  CMXBannerViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXBannerViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXBannerViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBannerImages:(NSArray*)images imageDuration:(CGFloat)duration {
    
    _imageView.animationImages = images;
    _imageView.animationDuration = duration * images.count;
    _imageView.animationRepeatCount = 0;   // repeat forever

    [_imageView stopAnimating];
    [_imageView startAnimating];
}

@end
