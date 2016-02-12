//
//  CMXNetwork.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXNetwork.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXNetwork ()

@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *password;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXNetwork

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXNetwork *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXNetwork *instance = [[CMXNetwork alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.ssid = [self objectOrNilForKey:@"ssid" fromDictionary:dict];
            self.password = [self objectOrNilForKey:@"password" fromDictionary:dict];

    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.ssid forKey:@"ssid"];
    [mutableDict setValue:self.password forKey:@"password"];

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

    self.ssid = [aDecoder decodeObjectForKey:@"ssid"];
    self.password = [aDecoder decodeObjectForKey:@"password"];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_ssid forKey:@"ssid"];
    [aCoder encodeObject:_password forKey:@"password"];
}


@end
