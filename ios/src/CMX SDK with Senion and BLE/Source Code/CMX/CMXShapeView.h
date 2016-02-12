//
//  CMXShapeView.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Internal view subclasse that manages a CAShapeLayer. Used to draw navigation path. */
@interface CMXShapeView : UIView

@property BOOL hitTestUsingPath;

@property (copy) UIBezierPath *path;

@property UIColor *fillColor;

@property (copy) NSString *fillRule;

@property UIColor *strokeColor;

@property CGFloat strokeStart, strokeEnd;

@property CGFloat lineWidth;

@property CGFloat miterLimit;

@property (copy) NSString *lineCap;

@property (copy) NSString *lineJoin;

@property CGFloat lineDashPhase;

@property (copy) NSArray *lineDashPattern;

@end
