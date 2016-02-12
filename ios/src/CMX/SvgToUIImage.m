//
//  SvgToUIImage.m
//  UIImageFromSVG
//
//  Created by Perli Alban on 05/11/13.
//  Copyright (c) 2013 Alban Perli. All rights reserved.
//

#import "SvgToUIImage.h"
#import <QuartzCore/QuartzCore.h>
#import "SMXMLDocument.h"

@interface SvgToUIImage ()
{
    NSInteger height,width;
}

/**
 *  CallBack
 **/
@property (copy) GeneratedUIImageCallBackBlock callBack;

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation SvgToUIImage

- (id)init
{
    self = [super init];
    if (self) {
        
        // To DO : dynamic height and width
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(-2000, 0, 768, 1024)];
        self.webView.delegate = self;
         self.webView.scalesPageToFit = YES;
        [self.webView setContentMode:UIViewContentModeScaleToFill];
        [[[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view] addSubview:self.webView];

       
        [self.webView setBackgroundColor:[UIColor clearColor]];
        [self.webView setOpaque:NO];
        
    }
    return self;
}

-(void)loadSVGData:(NSData*)svgData onComplete:(GeneratedUIImageCallBackBlock)callBack onFailure:(GeneratedUIImageErrorCallBackBlock)failure{

        NSError *error;

        self.callBack = callBack;
        
        SMXMLDocument *document = [SMXMLDocument documentWithData:svgData error:&error];
        
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        
        width = [[document.root attributeNamed:@"width"] integerValue];
        height = [[document.root attributeNamed:@"height"] integerValue];
        //NSLog(@"Original svg size : Width %i Height %i",width,height);
        [self.webView loadData:svgData MIMEType:@"image/svg+xml" textEncodingName:@"utf-8" baseURL:nil];
        
        self.webView.scalesPageToFit = YES;
}

-(UIImage*)svgData:(NSData*)svgData{
    
    NSError *error;
    
    SMXMLDocument *document = [SMXMLDocument documentWithData:svgData error:&error];
    
    width = [[document.root attributeNamed:@"width"] integerValue];
    height = [[document.root attributeNamed:@"height"] integerValue];
    //NSLog(@"Original svg size : Width %i Height %i",width,height);
    [self.webView loadData:svgData MIMEType:@"image/svg+xml" textEncodingName:@"utf-8" baseURL:nil];
    
    self.webView.scalesPageToFit = YES;
    
    UIImage *viewImage;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    UIImage *viewImage;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (self.callBack) {
        self.callBack(viewImage);
    }

}

-(void)dealloc{
    [self.webView removeFromSuperview];
}

@end
