//
//  CMXVenuesInfos.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXVenue.h"
#import "CMXNetwork.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXVenue ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *preferredNetworks;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *streetAddress;
@property (nonatomic, assign) NSUInteger locationUpdateInterval;
@property (nonatomic, assign) CMXWifiConnectionMode wifiMode;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXVenue


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXVenue *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXVenue *instance = [[CMXVenue alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.identifier = [self objectOrNilForKey:@"venueId" fromDictionary:dict];
    NSObject *receivedPreferredNetwork = [dict objectForKey:@"preferredNetwork"];
    NSMutableArray *parsedPreferredNetwork = [NSMutableArray array];
    if ([receivedPreferredNetwork isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedPreferredNetwork) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedPreferredNetwork addObject:[CMXNetwork modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedPreferredNetwork isKindOfClass:[NSDictionary class]]) {
       [parsedPreferredNetwork addObject:[CMXNetwork modelObjectWithDictionary:(NSDictionary *)receivedPreferredNetwork]];
    }

    self.preferredNetworks = [NSArray arrayWithArray:parsedPreferredNetwork];
            self.name = [self objectOrNilForKey:@"name" fromDictionary:dict];
            self.streetAddress = [self objectOrNilForKey:@"streetAddress" fromDictionary:dict];

    }
    
    self.locationUpdateInterval = [[self objectOrNilForKey:@"locationUpdateInterval" fromDictionary:dict] floatValue];
    self.wifiMode = [self objectOrNilForKey:@"wifiConnectionMode" fromDictionary:dict] ? stringToConnectionMode([self objectOrNilForKey:@"wifiConnectionMode" fromDictionary:dict]) : MANUAL;
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.identifier forKey:@"venueId"];
NSMutableArray *tempArrayForPreferredNetwork = [NSMutableArray array];
    for (NSObject *subArrayObject in self.preferredNetworks) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForPreferredNetwork addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForPreferredNetwork addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForPreferredNetwork] forKey:@"preferredNetwork"];
    [mutableDict setValue:self.name forKey:@"name"];
    [mutableDict setValue:self.streetAddress forKey:@"streetAddress"];
    [mutableDict setValue:[NSNumber numberWithUnsignedInteger:self.locationUpdateInterval] forKey:@"locationUpdateInterval"];
    [mutableDict setValue:connectionModeToString(self.wifiMode) forKey:@"wifiConnectionMode"];

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

    self.identifier = [aDecoder decodeObjectForKey:@"venueId"];
    self.preferredNetworks = [aDecoder decodeObjectForKey:@"preferredNetwork"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.streetAddress = [aDecoder decodeObjectForKey:@"streetAddress"];
    self.locationUpdateInterval = [aDecoder decodeIntegerForKey:@"locationUpdateInterval"];
    self.wifiMode = stringToConnectionMode([aDecoder decodeObjectForKey:@"wifiConnectionMode"]);
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:@"venueId"];
    [aCoder encodeObject:_preferredNetworks forKey:@"preferredNetwork"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_streetAddress forKey:@"streetAddress"];
    [aCoder encodeInteger:_locationUpdateInterval forKey:@"locationUpdateInterval"];
    [aCoder encodeObject:connectionModeToString(_wifiMode) forKey:@"wifiConnectionMode"];
}


@end
