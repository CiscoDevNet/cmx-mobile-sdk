//
//  CMXMenuItem.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Item of menu
 */
@interface CMXMenuItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *level;
@property (strong, nonatomic) NSString *floorID;
@property (strong, nonatomic) NSString *venueID;
@property (strong, nonatomic) NSArray *children;
@property (strong, nonatomic) UIImage* image;

+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children;
- (id)initWithName:(NSString *)name children:(NSArray *)array;

@end
