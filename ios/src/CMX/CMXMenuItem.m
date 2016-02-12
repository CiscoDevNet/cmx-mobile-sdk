//
//  CMXMenuItem.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXMenuItem.h"

@implementation CMXMenuItem


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children
{
    return [[self alloc] initWithName:name children:children];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithName:(NSString *)name children:(NSArray *)children
{
  self = [super init];
  if (self) {
    self.children = children;
    self.name = name;
  }
  return self;
}

@end
