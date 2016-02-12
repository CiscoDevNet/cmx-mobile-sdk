//
//  CMXFloor.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXFloor.h"
#import "CMXDimension.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXFloor ()

@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) CMXDimension *dimension;
@property (nonatomic, strong) NSString *mapHierarchyString;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXFloor


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CMXFloor *)modelObjectWithDictionary:(NSDictionary *)dict
{
    CMXFloor *instance = [[CMXFloor alloc] initWithDictionary:dict];
    return instance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.dimension = [CMXDimension modelObjectWithDictionary:[dict objectForKey:@"dimension"]];
            self.mapHierarchyString = [self objectOrNilForKey:@"mapHierarchyString" fromDictionary:dict];
            self.venueId = [self objectOrNilForKey:@"venueid" fromDictionary:dict];
            self.identifier = [self objectOrNilForKey:@"floorId" fromDictionary:dict];

    }
    
    return self;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.dimension dictionaryRepresentation] forKey:@"dimension"];
    [mutableDict setValue:self.mapHierarchyString forKey:@"mapHierarchyString"];
    [mutableDict setValue:self.venueId forKey:@"venueid"];
    [mutableDict setValue:self.identifier forKey:@"floorId"];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) name {
    NSArray* s = [_mapHierarchyString componentsSeparatedByString:@">"];
    return [s lastObject];
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

    self.dimension = [aDecoder decodeObjectForKey:@"dimension"];
    self.mapHierarchyString = [aDecoder decodeObjectForKey:@"mapHierarchyString"];
    self.venueId = [aDecoder decodeObjectForKey:@"venueid"];
    self.identifier = [aDecoder decodeObjectForKey:@"floorId"];
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_dimension forKey:@"dimension"];
    [aCoder encodeObject:_mapHierarchyString forKey:@"mapHierarchyString"];
    [aCoder encodeObject:_venueId forKey:@"venueid"];
    [aCoder encodeObject:_identifier forKey:@"floorId"];
}


@end
