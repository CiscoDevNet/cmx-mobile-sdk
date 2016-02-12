//
//  CMXMapView.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMXMapViewDelegate;

@class CMXPath;
@class CMXDimension;
@class CMXClientLocation;
@class CMXPoi;

/**
 *  View that displays pois/path on map with zoom/scrolling.
 */
@interface CMXMapView : UIScrollView<UIScrollViewDelegate>

/**
 *  Map delegate.
 */
@property (nonatomic, assign) id<CMXMapViewDelegate> mapDelegate;

/**
 *  Setup the view with map infos.
 *
 *  @param mapImage  Image of the map.
 *  @param dimension Dimension of the map.
 */
-(void) setupWithMapImage:(UIImage*)mapImage mapDimension:(CMXDimension*)dimension;

/**
 *  Display a poi on map.
 *
 *  @param poi   Poi to display
 *  @param image Image to display for the poi
 */
- (void) showPOI:(CMXPoi*)poi withImage:(UIImage*)image;

/**
 *  Show navigation path on map. Set nil to path parameter to clear the current path.
 *
 *  @param path      Path to display.
 *  @param color     Color of the path.
 *  @param lineWidth Width of the line.
 *  @param image     Image representing the target destination.
 */
-(void) showPath:(CMXPath*)path withColor:(UIColor*)color lineWith:(NSUInteger)lineWidth targetImage:(UIImage*)image;

/**
 *  Display user location on map.
 *
 *  @param userLocation User location on map.
 *  @param image        Image representing user on map.
 */
-(void) showUserLocation:(CMXClientLocation*)userLocation withImage:(UIImage*)image;

/**
 *  Display user location with orientation on map.
 *
 *  @param userLocation User location on the map.
 *  @param orientation  Orientation of the user (in degrees)
 *  @param image        Image representing the user on map.
 */
-(void) showUserLocation:(CMXClientLocation*)userLocation withOrientation:(float)orientation image:(UIImage*)image;

/**
 *  Center the map on given poi.
 *
 *  @param poi Poi to center.
 *  @param animated YES if animated, NO otherwise.
 */
-(void) centerOnPoi:(CMXPoi*)poi animated:(BOOL)animated;

/**
 *  Remove all displayed pois
 */
-(void) cleanMapView;

/**
 *  Update minimum and maximum zoom scales depending of the view size.
 */
-(void) updateMinMaxZoomScales;

/**
 *  Display a callout view on selected poi.
 *
 *  @param poi Selected poi.
 *  @param animated YES if animated, NO otherwise.
 */
-(void) displayCalloutOnPoi:(CMXPoi*)poi animated:(BOOL)animated;

/**
 *  Remove location feedback view from the map view.
 */
-(void) cleanLocationFeedback;

/**
 *  Set the image used by the feedback mode
 *
 *  @param image image representing the location feedback on the map.
 */
-(void) setLocationFeedbackImage:(UIImage*)image;

@end


/**
 *  Map view delegate protocol.
 */
@protocol CMXMapViewDelegate<NSObject>

@optional
/**
 *  Method called when a poi has been selected.
 *
 *  @param mapView Map view instance.
 *  @param poiId   Id of the selected poi.
 */
-(void) mapView:(CMXMapView*)mapView didSelectPoi:(NSString*)poiId;

/**
 *  Method called when a disclosure button of a callout has been pressed.
 *
 *  @param mapView Map view instance.
 *  @param poiId   Id of the selected poi.
 */
-(void) mapView:(CMXMapView*)mapView didDisclosePoi:(NSString*)poiId;

/**
 *  Method called when location feedback has been set.
 *
 *  @param mapView  Map view instance.
 *  @param location Location of the feedback.
 */
-(void) mapView:(CMXMapView*)mapView didSetLocationFeedback:(CGPoint)location;


@end

