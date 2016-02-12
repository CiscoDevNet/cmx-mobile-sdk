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

/*!
 * @header CMXMapView
 * This view manages the elements on the CMX Map along including the poi, routes, location feedback and the blue dot.
 * It also enables zooming / scrolling. 
 * @copyright Cisco Systems
 */


/*!
 * @class CMXMapView
 * @abstract View that displays pois/path on map with zoom/scrolling.
 */
@interface CMXMapView : UIScrollView<UIScrollViewDelegate>

/*!
 *  @property mapDelegate Map delegate.
 */
@property (nonatomic, assign) id<CMXMapViewDelegate> mapDelegate;

/*!
 *  @abstract Setup the mapview with map infos.
 *
 *  @param mapImage  Image of the map.
 *  @param dimension Dimension of the map.
 */
-(void) setupWithMapImage:(UIImage*)mapImage mapDimension:(CMXDimension*)dimension;

/*!
 *  @abstract Display a poi on map.
 *
 *  @param poi   Poi to display
 *  @param image Image to display for the poi
 */
- (void) showPOI:(CMXPoi*)poi withImage:(UIImage*)image;

/*!
 *  @abstract Show navigation path on map. Set nil to path parameter to clear the current path.
 *
 *  @param path      Path to display.
 *  @param color     Color of the path.
 *  @param lineWidth Width of the line.
 *  @param image     Image representing the target destination.
 */
-(void) showPath:(CMXPath*)path withColor:(UIColor*)color lineWith:(NSUInteger)lineWidth targetImage:(UIImage*)image;

/*!
 *  @abstract Display user location on map.
 *
 *  @param userLocation User location on map.
 *  @param image        Image representing user on map.
 */
-(void) showUserLocation:(CMXClientLocation*)userLocation withImage:(UIImage*)image;

/*!
 *  @abstract Display user location with orientation on map.
 *
 *  @param userLocation User location on the map.
 *  @param orientation  Orientation of the user (in degrees)
 *  @param image        Image representing the user on map.
 */
-(void) showUserLocation:(CMXClientLocation*)userLocation withOrientation:(float)orientation image:(UIImage*)image;

/*!
 *  @abstract Center the map on given poi.
 *
 *  @param poi Poi to center.
 *  @param animated YES if animated, NO otherwise.
 */
-(void) centerOnPoi:(CMXPoi*)poi animated:(BOOL)animated;

/*!
 *  @abstract Remove all displayed pois
 */
-(void) cleanMapView;

/*!
 * @abstract  Update minimum and maximum zoom scales depending of the view size.
 */
-(void) updateMinMaxZoomScales;

/*!
 *  @abstract Display a callout view on selected poi.
 *
 *  @param poi Selected poi.
 *  @param animated YES if animated, NO otherwise.
 */
-(void) displayCalloutOnPoi:(CMXPoi*)poi animated:(BOOL)animated;

/*!
 *  @abstract Remove location feedback view from the map view.
 */
-(void) cleanLocationFeedback;

/*!
 *  @abstract Set the image used by the feedback mode
 *
 *  @param image image representing the location feedback on the map.
 */
-(void) setLocationFeedbackImage:(UIImage*)image;

@end


/*!
 * @protocol Map view delegate protocol.
 */
@protocol CMXMapViewDelegate<NSObject>

@optional
/**
 *  @abstract Method called when a poi has been selected.
 *
 *  @param mapView Map view instance.
 *  @param poiId   Id of the selected poi.
 */
-(void) mapView:(CMXMapView*)mapView didSelectPoi:(NSString*)poiId;

/**
 *  @abstract Method called when a disclosure button of a callout has been pressed.
 *
 *  @param mapView Map view instance.
 *  @param poiId   Id of the selected poi.
 */
-(void) mapView:(CMXMapView*)mapView didDisclosePoi:(NSString*)poiId;

/**
 *  @abstract Method called when location feedback has been set.
 *
 *  @param mapView  Map view instance.
 *  @param location Location of the feedback.
 */
-(void) mapView:(CMXMapView*)mapView didSetLocationFeedback:(CGPoint)location;


@end

