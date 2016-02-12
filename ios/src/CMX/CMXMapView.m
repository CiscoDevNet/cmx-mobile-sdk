//
//  CMXMapView.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXMapView.h"
#import "CMXShapeView.h"

#import "CMXDimension.h"
#import "CMXMapCoordinate.h"
#import "CMXClientLocation.h"
#import "CMXPoi.h"
#import "CMXPath.h"
#import "CMXPoint.h"
#import "CMXClient.h"

#import "SMCalloutView.h"

#import <QuartzCore/QuartzCore.h>

#define DEG_TO_RAD(x) (x * M_PI / 180.0f)

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface PoiTagView : UIButton
/**
 *  Poi identifier
 **/
@property (nonatomic,strong) NSString *poiIdentifier;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation PoiTagView

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXMapView ()<SMCalloutViewDelegate>

/** Background map. */
@property (nonatomic, strong) UIImageView *rootImageView;

/** Backgroup map size. */
@property (nonatomic, assign) CGSize rootImageSize;

/** Map dimension. Used to convert world coordinates into image frame */
@property (nonatomic, strong) CMXDimension *mapDimension;

/** User image view.  **/
@property (nonatomic, strong) UIImageView *userImageView;

/** View holding the navigation path. */
@property (nonatomic, weak) CMXShapeView* pathLayerView;

/** Line width of the navigation path. */
@property (nonatomic, assign) NSUInteger pathLineWidth;

/**
 *  CalloutView called on poi click
 **/
@property (nonatomic, strong) SMCalloutView *calloutView;

/**
 *  Selected poi id
 **/
@property (nonatomic, strong) NSString*  selectedPoiId;

/**
 *  flag set when feedback mode is enabled.
 **/
@property (nonatomic, assign) BOOL feedbackModeEnabled;

/** User image view.  **/
@property (nonatomic, strong) UIImageView *feedbackImageView;

/** User image view.  **/
@property (nonatomic, strong) UIImage *feedbackImage;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXMapView


#pragma mark - UIView
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [super setDelegate:self];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(_rootImageView) {
        // center the image as it becomes smaller than the size of the screen
        CGSize boundsSize = self.bounds.size;
        CGRect frameToCenter = _rootImageView.frame;
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width)
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        else
            frameToCenter.origin.x = 0;
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height)
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        else
            frameToCenter.origin.y = 0;
        
        _rootImageView.frame = frameToCenter;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_calloutView) {
        [_calloutView dismissCalloutAnimated:YES];
        self.selectedPoiId = nil;
    }
}

#pragma mark - Public
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setupWithMapImage:(UIImage *)mapImage mapDimension:(CMXDimension*)dimension {
    
    if (mapImage != nil) {
        CGSize imageSize = mapImage.size;
        
        self.mapDimension = dimension;
        
        // Remove all subviews
        if(_rootImageView) {
            [_rootImageView removeFromSuperview];
            self.rootImageView = nil;
        }
        if(_pathLayerView) {
            [_pathLayerView removeFromSuperview];
            self.pathLayerView = nil;
        }
        if(_userImageView) {
            [_userImageView removeFromSuperview];
            self.userImageView = nil;
        }
        if(_feedbackImageView) {
            [_feedbackImageView removeFromSuperview];
            self.feedbackImageView = nil;
        }
        
        self.rootImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        _rootImageView.backgroundColor = [UIColor clearColor];
        _rootImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rootImageView.image = mapImage;
        _rootImageView.userInteractionEnabled = YES;
        _rootImageView.autoresizesSubviews = YES;
        self.rootImageSize = mapImage.size;
        self.contentSize = imageSize;
        [self addSubview:_rootImageView];
        
        
        CMXShapeView *pathView = [[CMXShapeView alloc] initWithFrame:_rootImageView.bounds];
        pathView.fillColor = nil;
        [_rootImageView addSubview:pathView];
        self.pathLayerView = pathView;

        [self updateMinMaxZoomScales];
        self.zoomScale = self.minimumZoomScale;  // start out with the content fully visible
    }
    
    self.calloutView = [[SMCalloutView alloc] init];
    _calloutView.delegate = self;
    _calloutView.title = @"";

    self.feedbackModeEnabled = NO;

    // TODO
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) { // iOS 7 & earlier
        UIButton *topDisclosure = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [topDisclosure setImage:[UIImage imageNamed:@"arrow_right_white.png"] forState:UIControlStateNormal];
        [topDisclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
        topDisclosure.frame = CGRectMake(.0, -.40, 40, 40);

        _calloutView.rightAccessoryView = topDisclosure;
    }
    else {
        UIButton *topDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [topDisclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
        _calloutView.rightAccessoryView = topDisclosure;
    }
	_calloutView.shouldDrawiOS7UserInterface = NO; // TODO
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPOI:(CMXPoi*)poi withImage:(UIImage*)image {
    
    if (poi && image) {
        
        float invZoomScale = 1.0f / self.zoomScale;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
        
        // TODO: define min/max size
        PoiTagView *btn = [[PoiTagView alloc] initWithFrame:CGRectMake(0, 0, image.size.width / 2, image.size.height / 2)];
        
        btn.poiIdentifier = poi.identifier;

        [btn addTarget:self action:@selector(poiBtClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setImage:image forState:UIControlStateNormal];
        
        btn.transform = scaleTransform;
        
        float centerX = 0;
        float centerY = 0;
        
        for(CMXPoint* point in poi.points) {
            centerX += point.x;
            centerY += point.y;
        }
        
        centerX = centerX / poi.points.count;
        centerY = centerY / poi.points.count;
        
        btn.center = [self convertX:centerX y:centerY];
        
        [_rootImageView addSubview:btn];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showPath:(CMXPath*)path_ withColor:(UIColor*)color lineWith:(NSUInteger)lineWidth targetImage:(UIImage*)image {
    if(path_) {
        // Build bezier path with given points
        UIBezierPath* bezier = [[UIBezierPath alloc] init];
        bezier.lineCapStyle = kCGLineCapRound;
        bezier.lineJoinStyle = kCGLineJoinRound;
        if(path_.points.count >= 2) {
            CMXPoint* firstPoint = [path_.points objectAtIndex:0];
            [bezier moveToPoint:[self convertPoint:firstPoint]];
            
            for(int i=1; i<path_.points.count; ++i) {
                CMXPoint* point = [path_.points objectAtIndex:i];
                [bezier addLineToPoint:[self convertPoint:point]];
            }
        }
        _pathLayerView.path = bezier;
        
        _pathLayerView.strokeColor = color;
        self.pathLineWidth = lineWidth;
        _pathLayerView.lineWidth =  self.pathLineWidth / self.zoomScale;
        
        // Add end point button
        if(image && path_.points.count >= 2) {
            CMXPoint* lastPoint = [path_.points lastObject];
            
            UIButton *btn = (UIButton*)[_pathLayerView viewWithTag:555];
            if(!btn) {
                btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                btn.tag = 555;
            }
            [btn setImage:image forState:UIControlStateNormal];
            
            btn.center = [self convertPoint:lastPoint];
            
            float invZoomScale = 1.0f / self.zoomScale;
            btn.transform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
            
            [_pathLayerView addSubview:btn];
        }
    }
    else {
        _pathLayerView.path = nil;
        UIButton *btn = (UIButton*)[_pathLayerView viewWithTag:555];
        [btn removeFromSuperview];
    }
    
    [_pathLayerView setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showUserLocation:(CMXClientLocation*)userLocation withImage:(UIImage*)image {
    
    [self showUserLocation:userLocation withOrientation:0 image:image];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showUserLocation:(CMXClientLocation*)userLocation withOrientation:(float)orientation image:(UIImage*)image {

    if(!userLocation) {
        // No location, hide the view
        _userImageView.hidden = YES;
    }
    else {
        _userImageView.hidden = NO;
        // check if this is the first display
        if(!_userImageView) {
            if(image && _mapDimension) {
                self.userImageView = [[UIImageView alloc] initWithImage:image];
                _userImageView.backgroundColor = [UIColor clearColor];
                _userImageView.contentMode = UIViewContentModeScaleAspectFit;
                _userImageView.center = [self convertCoordinate:userLocation.mapCoordinate];
                float invZoomScale = 1.0f / self.zoomScale;
                CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
                CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(DEG_TO_RAD(orientation));
                _userImageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform);
                [_rootImageView addSubview:_userImageView];

                UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveFeedbackLocationAction:)];
                //longpressGesture.minimumPressDuration = 1;
                [_userImageView addGestureRecognizer:longpressGesture];
                _userImageView.userInteractionEnabled = YES;

                [self setNeedsDisplay];
            }
        }
        else {
            if(_userImageView.image != image) {
                _userImageView.image = image;
            }
            float invZoomScale = 1.0f / self.zoomScale;
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(DEG_TO_RAD(orientation));
            // Display smooth animation to show the new location
            [UIView animateWithDuration:0.3 animations:^{
                _userImageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform);
                _userImageView.center = [self convertCoordinate:userLocation.mapCoordinate];
            }];
            [_rootImageView bringSubviewToFront:_userImageView];
        }
        
        if (_calloutView)
            [_rootImageView bringSubviewToFront:_calloutView];

    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)centerOnPoi:(CMXPoi *)targetPOI animated:(BOOL)animated {

    NSArray* poisViews = _rootImageView.subviews;
    for(UIView* poiView in poisViews) {
        if ([poiView isKindOfClass:[PoiTagView class]]) {
            PoiTagView *targetPOIView = (PoiTagView*)poiView;
            if ([targetPOIView.poiIdentifier isEqualToString:targetPOI.identifier]) {
                
                CGPoint center = targetPOIView.center;
                
                center.x *= self.zoomScale;
                center.y *= self.zoomScale;
                
                CGRect rect = CGRectMake(center.x - self.frame.size.width/2.0,
                                         center.y - self.frame.size.height/2.0,
                                         self.frame.size.width,
                                         self.frame.size.height);
                [self scrollRectToVisible:rect animated:animated];
                break;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) displayCalloutOnPoi:(CMXPoi *)poi animated:(BOOL)animated {
    [_calloutView dismissCalloutAnimated:NO];
    _calloutView.contentView = nil;
    _calloutView.backgroundView = [SMCalloutBackgroundView systemBackgroundView]; // use the system graphics
	_calloutView.shouldDrawiOS7UserInterface = NO; // TODO
    _calloutView.title = poi.name;

    if (_calloutView.rightAccessoryView ==  nil) {
        UIButton *topDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [topDisclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
        _calloutView.rightAccessoryView = topDisclosure;
    }

    NSArray* poisViews = _rootImageView.subviews;
    for(UIView* poiView in poisViews) {
        if ([poiView isKindOfClass:[PoiTagView class]]) {
            PoiTagView *targetPOIView = (PoiTagView*)poiView;
            if ([targetPOIView.poiIdentifier isEqualToString:poi.identifier]) {

                CGPoint center = targetPOIView.center;
                [_calloutView presentCalloutFromRect:CGRectMake(center.x, center.y-poiView.frame.size.height/2, 2, 2)
                                              inView:_rootImageView
                                   constrainedToView:_rootImageView
                            permittedArrowDirections:SMCalloutArrowDirectionAny
                                            animated:animated];
                break;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updateMinMaxZoomScales {
    CGSize boundsSize = [self bounds].size;
    
    // set up our content size and min/max zoomscale
    CGFloat xScale = boundsSize.width / self.rootImageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / self.rootImageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    CGFloat maxScale = 4.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    if(self.zoomScale < minScale) self.zoomScale = minScale;
    else if(self.zoomScale > maxScale) self.zoomScale = maxScale;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cleanMapView {
    // Remove current poi views
    for(UIView* view in _rootImageView.subviews) {
        if([view isKindOfClass:[PoiTagView class]]) {
            [view removeFromSuperview];
        }
    }
    [_calloutView dismissCalloutAnimated:NO];
    _selectedPoiId = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) cleanLocationFeedback {
    [_feedbackImageView removeFromSuperview];
    self.feedbackImageView = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setLocationFeedbackImage:(UIImage*)image {
    self.feedbackImage = image;
}

#pragma mark - UIView events
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) moveFeedbackLocationAction:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        [self enableFeedbackMode:YES];
    }
    else if(gesture.state == UIGestureRecognizerStateChanged) {
        //move your views here.
        CGPoint point = [gesture locationInView:_rootImageView];
        _feedbackImageView.center = point;
    }
    else if(gesture.state == UIGestureRecognizerStateEnded) {
        [self enableFeedbackMode:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) poiBtClickedAction:(PoiTagView*)poiBtn {

    _selectedPoiId = poiBtn.poiIdentifier;
    if([_mapDelegate respondsToSelector:@selector(mapView:didSelectPoi:)]) {
        [_mapDelegate mapView:self didSelectPoi:poiBtn.poiIdentifier];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) disclosureTapped {
    [_calloutView dismissCalloutAnimated:NO];

    if([_mapDelegate respondsToSelector:@selector(mapView:didDisclosePoi:)]) {
        [_mapDelegate mapView:self didDisclosePoi:_selectedPoiId];
    }
}

#pragma mark - UIScrollView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _rootImageView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // Scale some views to get constant zoom
    
    float invZoomScale = 1.0f / self.zoomScale;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
    
    NSArray* poisViews = _rootImageView.subviews;
    for(UIView* poiView in poisViews) {
        
        if ([poiView isKindOfClass:[PoiTagView class]]) {
            poiView.transform = scaleTransform;
        }
    }
    
    _userImageView.transform = scaleTransform;
    _feedbackImageView.transform = scaleTransform;

    // Set constant path line width
    float w = self.pathLineWidth / self.zoomScale;
    _pathLayerView.lineWidth = w ;
    
    UIView *btn = [_pathLayerView viewWithTag:555];
    btn.transform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
    
    [_pathLayerView addSubview:btn];
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
// Convert map coordinate to image coordinate
-(CGPoint) convertCoordinate:(CMXMapCoordinate*)coordinate {
    return [self convertX:coordinate.x y:coordinate.y];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Convert point coordinate to image coordinate
-(CGPoint) convertPoint:(CMXPoint*)point {
    return [self convertX:point.x y:point.y];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGPoint) convertX:(float)x y:(float)y {
    CGPoint p = CGPointMake((x  * self.rootImageSize.width) / _mapDimension.width,
                            (y  * self.rootImageSize.height) / _mapDimension.length);
    return p;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//-(void) centerMapOnUserLocation {
//
//    if (self.userImageView != nil) {
//        CGPoint center = self.userImageView.center;
//
//        _calloutView.contentView = nil;
//        _calloutView.backgroundView = [SMCalloutBackgroundView systemBackgroundView]; // use the system graphics
//        _calloutView.shouldDrawiOS7UserInterface = NO;
//        _calloutView.title = NSLocalizedString(@"Your location", @"");
//        _calloutView.rightAccessoryView = nil;
//
//        [_calloutView presentCalloutFromRect:CGRectMake(center.x, center.y-self.userImageView.frame.size.height/2, 2, 2)
//                                      inView:_rootImageView
//                           constrainedToView:_rootImageView
//                    permittedArrowDirections:SMCalloutArrowDirectionAny
//                                    animated:YES];
//        center.x *= self.zoomScale;
//        center.y *= self.zoomScale;
//        CGRect rect = CGRectMake(center.x - self.frame.size.width/2.0,
//                                 center.y - self.frame.size.height/2.0,
//                                 self.frame.size.width,
//                                 self.frame.size.height);
//        [self scrollRectToVisible:rect animated:YES];
//
//    }
//    else {
//        // TO DO:
//        // open maps app
//
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"User location not found"
//                                                            message: @"Open maps application"
//                                                           delegate: self
//                                                  cancelButtonTitle: nil
//                                                  otherButtonTitles: @"OK", nil];
//        [alertView show];
//    }
//}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) enableFeedbackMode:(BOOL)enabled {
    if(enabled) {
        if(!_feedbackImageView) {
            self.feedbackImageView = [[UIImageView alloc] initWithImage:_feedbackImage ? _feedbackImage : _userImageView.image];
            _feedbackImageView.backgroundColor = [UIColor clearColor];
            _feedbackImageView.contentMode = UIViewContentModeScaleAspectFit;
            _feedbackImageView.center = _userImageView.center;
            [_rootImageView addSubview:_feedbackImageView];

            UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveFeedbackLocationAction:)];
            [_feedbackImageView addGestureRecognizer:longpressGesture];
            _feedbackImageView.userInteractionEnabled = YES;
        }

        float invZoomScale = 3.0f * 1.0f / self.zoomScale;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
        _feedbackImageView.transform = scaleTransform;
    }
    else {
        CGPoint location = _feedbackImageView.center;

        float invZoomScale =1.0f / self.zoomScale;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(invZoomScale, invZoomScale);
        _feedbackImageView.transform = scaleTransform;

        // Send new location to the delegate
        if([_mapDelegate respondsToSelector:@selector(mapView:didSetLocationFeedback:)]) {
            [_mapDelegate mapView:self didSetLocationFeedback:location];
        }
    }
}

@end
