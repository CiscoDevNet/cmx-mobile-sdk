//
//  CMXPOI.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXPoi.h"
#import "CMXPoint.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXPoi ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong, readwrite) NSArray *points;
@property (nonatomic, strong) NSString *imageType;
@property (nonatomic, strong) NSString *facebookPlaceId;
@property (nonatomic, strong) NSString *twitterPlaceId;


- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXPoi

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXPoi *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXPoi *instance = [[CMXPoi alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        NSObject *receivedPoints = [dict objectForKey:@"points"];
        NSMutableArray *parsedPoints = [NSMutableArray array];
        if ([receivedPoints isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedPoints) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedPoints addObject:[CMXPoint modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedPoints isKindOfClass:[NSDictionary class]]) {
            [parsedPoints addObject:[CMXPoint modelObjectWithDictionary:(NSDictionary *)receivedPoints]];
        }
        
        self.points = [NSArray arrayWithArray:parsedPoints];
        self.identifier = [self objectOrNilForKey:@"id" fromDictionary:dict];
        self.floorId = [self objectOrNilForKey:@"floorid" fromDictionary:dict];
        self.name = [self objectOrNilForKey:@"name" fromDictionary:dict];
        self.venueId = [self objectOrNilForKey:@"venueid" fromDictionary:dict];
        self.imageType = [self objectOrNilForKey:@"imageType" fromDictionary:dict];
        self.facebookPlaceId = [self objectOrNilForKey:@"facebookPlaceid" fromDictionary:dict];
        self.twitterPlaceId = [self objectOrNilForKey:@"twitterPlaceid" fromDictionary:dict];
    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForPoints = [NSMutableArray array];
    for (NSObject *subArrayObject in self.points) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForPoints addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForPoints addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForPoints] forKey:@"points"];
    [mutableDict setValue:self.identifier forKey:@"id"];
    [mutableDict setValue:self.floorId forKey:@"floorid"];
    [mutableDict setValue:self.name forKey:@"name"];
    [mutableDict setValue:self.venueId forKey:@"venueid"];
    [mutableDict setValue:self.imageType forKey:@"imageType"];
    [mutableDict setValue:self.facebookPlaceId forKey:@"facebookPlaceid"];
    [mutableDict setValue:self.twitterPlaceId forKey:@"twitterPlaceid"];

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

    self.points = [aDecoder decodeObjectForKey:@"points"];
    self.identifier = [aDecoder decodeObjectForKey:@"id"];
    self.floorId = [aDecoder decodeObjectForKey:@"floorid"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.venueId = [aDecoder decodeObjectForKey:@"venueid"];
    self.imageType = [aDecoder decodeObjectForKey:@"imageType"];
    self.facebookPlaceId = [aDecoder decodeObjectForKey:@"facebookPlaceid"];
    self.twitterPlaceId = [aDecoder decodeObjectForKey:@"twitterPlaceid"];

    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_points forKey:@"points"];
    [aCoder encodeObject:_identifier forKey:@"id"];
    [aCoder encodeObject:_floorId forKey:@"floorid"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_venueId forKey:@"venueid"];
    [aCoder encodeObject:_imageType forKey:@"imageType"];
    [aCoder encodeObject:_facebookPlaceId forKey:@"facebookPlaceid"];
    [aCoder encodeObject:_twitterPlaceId forKey:@"twitterPlaceid"];
}


@end
