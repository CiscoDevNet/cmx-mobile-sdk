//
//  CMXBanner.m
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXBanner.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXBanner ()

@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSString *imageType;
@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *zoneId;
@property (nonatomic, strong) NSString *url;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXBanner


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXBanner *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXBanner *instance = [[CMXBanner alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.imageId = [self objectOrNilForKey:@"id" fromDictionary:dict];
            self.imageType = [self objectOrNilForKey:@"imageType" fromDictionary:dict];
            self.venueId = [self objectOrNilForKey:@"venueid" fromDictionary:dict];
            self.url = [self objectOrNilForKey:@"url" fromDictionary:dict];
            self.zoneId = [self objectOrNilForKey:@"zoneid" fromDictionary:dict];

    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.imageId forKey:@"id"];
    [mutableDict setValue:self.imageType forKey:@"imageType"];
    [mutableDict setValue:self.venueId forKey:@"venueid"];
    [mutableDict setValue:self.url forKey:@"url"];
    [mutableDict setValue:self.zoneId forKey:@"zoneid"];

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

    self.imageId = [aDecoder decodeObjectForKey:@"identifier"];
    self.imageType = [aDecoder decodeObjectForKey:@"imageType"];
    self.venueId = [aDecoder decodeObjectForKey:@"venueid"];
    self.url = [aDecoder decodeObjectForKey:@"url"];
    self.zoneId = [aDecoder decodeObjectForKey:@"zoneid"];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_imageId forKey:@"identifier"];
    [aCoder encodeObject:_imageType forKey:@"imageType"];
    [aCoder encodeObject:_venueId forKey:@"venueid"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_zoneId forKey:@"zoneid"];
}


@end
