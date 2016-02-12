//
//  MapCoordinate.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXMapCoordinate.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXMapCoordinate ()

//@property (nonatomic, assign) float x;
//@property (nonatomic, assign) float y;
//@property (nonatomic, assign) CMXUnit unit;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXMapCoordinate


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXMapCoordinate *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXMapCoordinate *instance = [[CMXMapCoordinate alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.x = [[self objectOrNilForKey:@"x" fromDictionary:dict] floatValue];
        self.y = [[self objectOrNilForKey:@"y" fromDictionary:dict] floatValue];
        self.unit = [self objectOrNilForKey:@"unit" fromDictionary:dict] ? stringToUnit([self objectOrNilForKey:@"unit" fromDictionary:dict]) : FEET;
    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithFloat:self.x] forKey:@"x"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.y] forKey:@"y"];
    [mutableDict setValue:unitToString(self.unit) forKey:@"unit"];

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

    self.x = [[aDecoder decodeObjectForKey:@"x"] floatValue];
    self.y = [[aDecoder decodeObjectForKey:@"y"] floatValue];
    self.unit = stringToUnit([aDecoder decodeObjectForKey:@"unit"]);
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:[NSNumber numberWithFloat:_x] forKey:@"x"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_y] forKey:@"y"];
    [aCoder encodeObject:unitToString(_unit) forKey:@"unit"];
}


@end
