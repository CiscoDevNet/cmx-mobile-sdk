//
//  CMXDimension.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXDimension.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXDimension ()

@property (nonatomic, assign) float height;
@property (nonatomic, assign) float length;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float offsetX;
@property (nonatomic, assign) float offsetY;
@property (nonatomic, assign) CMXUnit unit;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXDimension


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXDimension *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXDimension *instance = [[CMXDimension alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.height = [[self objectOrNilForKey:@"height" fromDictionary:dict] floatValue];
            self.offsetX = [[self objectOrNilForKey:@"offsetX" fromDictionary:dict] floatValue];
            self.length = [[self objectOrNilForKey:@"length" fromDictionary:dict] floatValue];
            self.width = [[self objectOrNilForKey:@"width" fromDictionary:dict] floatValue];
            self.offsetY = [[self objectOrNilForKey:@"offsetY" fromDictionary:dict] floatValue];
            self.unit = stringToUnit([self objectOrNilForKey:@"unit" fromDictionary:dict]);

    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithFloat:self.height] forKey:@"height"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.offsetX] forKey:@"offsetX"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.length] forKey:@"length"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.width] forKey:@"width"];
    [mutableDict setValue:[NSNumber numberWithFloat:self.offsetY] forKey:@"offsetY"];
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

    self.height = [[aDecoder decodeObjectForKey:@"height"] floatValue];
    self.offsetX = [[aDecoder decodeObjectForKey:@"offsetX"] floatValue];
    self.length = [[aDecoder decodeObjectForKey:@"length"] floatValue];
    self.width = [[aDecoder decodeObjectForKey:@"width"] floatValue];
    self.offsetY = [[aDecoder decodeObjectForKey:@"offsetY"] floatValue];
    self.unit = stringToUnit([aDecoder decodeObjectForKey:@"unit"]);
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:[NSNumber numberWithFloat:_height] forKey:@"height"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_offsetX] forKey:@"offsetX"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_length] forKey:@"length"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_width] forKey:@"width"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_offsetY] forKey:@"offsetY"];
    [aCoder encodeObject:unitToString(_unit) forKey:@"unit"];
}


@end
