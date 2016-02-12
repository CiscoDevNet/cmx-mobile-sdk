//
//  CMXPoint.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXPoint.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXPoint ()

/** X coordinate of the point */
@property (nonatomic, assign) float x;

/** Y coordinate of the point */
@property (nonatomic, assign) float y;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXPoint


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXPoint *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXPoint *instance = [[CMXPoint alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.x = [[dict objectForKey:@"x"] floatValue];
            self.y = [[dict objectForKey:@"y"] floatValue];

    }
    
    return self;
    
}

#pragma mark - Helper Method
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.x = [aDecoder decodeFloatForKey:@"x"];
    self.y = [aDecoder decodeFloatForKey:@"y"];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeFloat:_x forKey:@"x"];
    [aCoder encodeFloat:_y forKey:@"y"];
}


@end
