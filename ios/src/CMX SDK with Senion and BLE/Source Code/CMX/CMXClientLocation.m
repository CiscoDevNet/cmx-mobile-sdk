//
//  CMXClientLocation.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXClientLocation.h"
#import "CMXMapCoordinate.h"
#import "CMXGeoCoordinate.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXClientLocation ()

@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong) CMXMapCoordinate *mapCoordinate;
@property (nonatomic,strong) CMXGeoCoordinate *geoCoordinate;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *zoneId;
@property  (nonatomic,strong) NSString *lastLocationUpdateTime;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXClientLocation


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXClientLocation *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXClientLocation *instance = [[CMXClientLocation alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.venueId = [self objectOrNilForKey:@"venueId" fromDictionary:dict];
        self.mapCoordinate = [CMXMapCoordinate modelObjectWithDictionary:[dict objectForKey:@"mapCoordinate"]];
        self.geoCoordinate = [CMXGeoCoordinate modelObjectWithDictionary:[dict objectForKey:@"geoCoordinate"]];
        self.deviceId = [self objectOrNilForKey:@"deviceId" fromDictionary:dict];
        self.floorId = [self objectOrNilForKey:@"floorId" fromDictionary:dict];
        self.zoneId = [self objectOrNilForKey:@"zoneId" fromDictionary:dict];
        self.lastLocationUpdateTime = [self objectOrNilForKey:@"lastLocationUpdateTime" fromDictionary:dict];
    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.venueId forKey:@"venueId"];
    [mutableDict setValue:[self.mapCoordinate dictionaryRepresentation] forKey:@"mapCoordinate"];
    [mutableDict setValue:self.geoCoordinate forKey:@"geoCoordinate"];
    [mutableDict setValue:self.deviceId forKey:@"deviceId"];
    [mutableDict setValue:self.floorId forKey:@"floorId"];
    [mutableDict setValue:self.zoneId forKey:@"zoneId"];
    [mutableDict setValue:self.lastLocationUpdateTime forKey:@"lastLocationUpdateTime"];
    
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
    
    self.venueId = [aDecoder decodeObjectForKey:@"venueId"];
    self.mapCoordinate = [aDecoder decodeObjectForKey:@"mapCoordinate"];
    self.geoCoordinate = [aDecoder decodeObjectForKey:@"geoCoordinate"];
    self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
    self.floorId = [aDecoder decodeObjectForKey:@"floorId"];
    self.lastLocationUpdateTime = [aDecoder decodeObjectForKey:@"lastLocationUpdateTime"];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_venueId forKey:@"venueId"];
    [aCoder encodeObject:_mapCoordinate forKey:@"mapCoordinate"];
    [aCoder encodeObject:_geoCoordinate forKey:@"geoCoordinate"];
    [aCoder encodeObject:_deviceId forKey:@"deviceId"];
    [aCoder encodeObject:_floorId forKey:@"floorId"];
    [aCoder encodeObject:_lastLocationUpdateTime forKey:@"lastLocationUpdateTime"];
}


@end
