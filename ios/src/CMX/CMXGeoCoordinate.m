//
//  GeoCoordinate.m
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXGeoCoordinate.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXGeoCoordinate ()

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXGeoCoordinate


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXGeoCoordinate *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXGeoCoordinate *instance = [[CMXGeoCoordinate alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.latitude = [[self objectOrNilForKey:@"latitude" fromDictionary:dict] floatValue];
        self.longitude = [[self objectOrNilForKey:@"longitude" fromDictionary:dict] floatValue];
    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithFloat:self.latitude] forKey:@"latitude"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.longitude] forKey:@"longitude"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
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
    
    self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] floatValue];
    self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] floatValue];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:[NSNumber numberWithFloat:_latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_longitude] forKey:@"longitude"];
}


@end
