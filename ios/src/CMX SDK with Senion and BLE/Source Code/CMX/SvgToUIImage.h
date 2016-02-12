//
//  SvgToUIImage.h
//  UIImageFromSVG
//
//  Created by Perli Alban on 05/11/13.
//  Copyright (c) 2013 Alban Perli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^GeneratedUIImageCallBackBlock)(UIImage*);
typedef void(^GeneratedUIImageErrorCallBackBlock)(NSError*);
@interface SvgToUIImage : NSObject<UIWebViewDelegate>



-(void)loadSVGData:(NSData*)svgData onComplete:(GeneratedUIImageCallBackBlock)callBack onFailure:(GeneratedUIImageErrorCallBackBlock)failure;

-(UIImage*)svgData:(NSData*)svgData;

@end
