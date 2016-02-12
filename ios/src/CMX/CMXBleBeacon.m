//
//  CMXBleBeacon.m
//  CMX
//
//  Created by Abhishek Bhattacharyya on 5/30/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import "CMXBleBeacon.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXBleBeacon ()

@property (nonatomic, strong) NSString *uuid;

@property (nonatomic, strong) NSString *major;

@property (nonatomic, strong) NSString *minor;

@property (nonatomic, strong) NSString *mfgId;

@property (nonatomic, strong) NSString *calRssi;

@property (nonatomic, strong) NSString *floorId;

@property (nonatomic, strong) NSString *xCord;

@property (nonatomic, strong) NSString *yCord;

@property (nonatomic, strong) NSString *zCord;

@property (nonatomic, strong) NSString *bleBeaconName;

@property (nonatomic, strong) NSString *bleBeaconType;

@property (nonatomic, strong) NSString *regionIdentifier;

@property (nonatomic, strong) NSString *zoneId;

@property (nonatomic, strong) NSString *message;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CMXBleBeacon

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXBleBeacon *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXBleBeacon *instance = [[CMXBleBeacon alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.uuid = [self objectOrNilForKey:@"uuid" fromDictionary:dict];
        self.major = [self objectOrNilForKey:@"major" fromDictionary:dict];
        self.minor = [self objectOrNilForKey:@"minor" fromDictionary:dict];
        self.mfgId = [self objectOrNilForKey:@"mfgId" fromDictionary:dict];
        self.calRssi = [self objectOrNilForKey:@"calRssi" fromDictionary:dict];
        self.floorId = [self objectOrNilForKey:@"floorId" fromDictionary:dict];
        self.xCord = [self objectOrNilForKey:@"xCord" fromDictionary:dict];
        self.yCord = [self objectOrNilForKey:@"yCord" fromDictionary:dict];
        self.zCord = [self objectOrNilForKey:@"zCord" fromDictionary:dict];
        self.bleBeaconName = [self objectOrNilForKey:@"bleBeaconName" fromDictionary:dict];
        self.bleBeaconType = [self objectOrNilForKey:@"bleBeaconType" fromDictionary:dict];
        self.regionIdentifier = [self objectOrNilForKey:@"regionIdentifier" fromDictionary:dict];
        self.zoneId = [self objectOrNilForKey:@"zoneId" fromDictionary:dict];
        self.message = [self objectOrNilForKey:@"message" fromDictionary:dict];
        
    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.uuid forKey:@"uuid"];
    [mutableDict setValue:self.major forKey:@"major"];
    [mutableDict setValue:self.minor forKey:@"minor"];
    [mutableDict setValue:self.mfgId forKey:@"mfgId"];
    [mutableDict setValue:self.calRssi forKey:@"calRssi"];
    [mutableDict setValue:self.floorId forKey:@"floorId"];
    [mutableDict setValue:self.xCord forKey:@"xCord"];
    [mutableDict setValue:self.yCord forKey:@"yCord"];
    [mutableDict setValue:self.zCord forKey:@"zCord"];
    [mutableDict setValue:self.bleBeaconName forKey:@"bleBeaconName"];
    [mutableDict setValue:self.bleBeaconType forKey:@"bleBeaconType"];
    [mutableDict setValue:self.regionIdentifier forKey:@"regionIdentifier"];
    [mutableDict setValue:self.zoneId forKey:@"zoneId"];
    [mutableDict setValue:self.message forKey:@"message"];
    
    
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
    
    self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
    self.major = [aDecoder decodeObjectForKey:@"major"];
    self.minor = [aDecoder decodeObjectForKey:@"minor"];
    self.mfgId = [aDecoder decodeObjectForKey:@"mfgId"];
    self.calRssi = [aDecoder decodeObjectForKey:@"calRssi"];
    self.floorId = [aDecoder decodeObjectForKey:@"floorId"];
    self.xCord = [aDecoder decodeObjectForKey:@"xCord"];
    self.yCord = [aDecoder decodeObjectForKey:@"yCord"];
    self.zCord = [aDecoder decodeObjectForKey:@"zCord"];
    self.bleBeaconName = [aDecoder decodeObjectForKey:@"bleBeaconName"];
    self.bleBeaconType = [aDecoder decodeObjectForKey:@"bleBeaconType"];
    self.regionIdentifier = [aDecoder decodeObjectForKey:@"regionIdentifier"];
    self.zoneId = [aDecoder decodeObjectForKey:@"zoneId"];
    self.message = [aDecoder decodeObjectForKey:@"message"];
    
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.major forKey:@"major"];
    [aCoder encodeObject:self.minor forKey:@"minor"];
    [aCoder encodeObject:self.mfgId forKey:@"mfgId"];
    [aCoder encodeObject:self.calRssi forKey:@"calRssi"];
    [aCoder encodeObject:self.floorId forKey:@"floorId"];
    [aCoder encodeObject:self.xCord forKey:@"xCord"];
    [aCoder encodeObject:self.yCord forKey:@"yCord"];
    [aCoder encodeObject:self.zCord forKey:@"zCord"];
    [aCoder encodeObject:self.bleBeaconName forKey:@"bleBeaconName"];
    [aCoder encodeObject:self.bleBeaconType forKey:@"bleBeaconType"];
    [aCoder encodeObject:self.regionIdentifier forKey:@"regionIdentifier"];
    [aCoder encodeObject:self.zoneId forKey:@"zoneId"];
    [aCoder encodeObject:self.message forKey:@"message"];
}


@end
