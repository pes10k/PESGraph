//
//  PESGraphEdge.m
//  PESGraph
//
//  Created by Peter Snyder on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PESGraphEdge.h"

@implementation PESGraphEdge

@synthesize name;
@synthesize weight;

#pragma mark -
#pragma mark Class Methods

+ (PESGraphEdge *)edgeWithName:(NSString *)aName andWeight:(NSNumber *)aNumber {
    
    PESGraphEdge *anEdge = [[PESGraphEdge alloc] init];

    anEdge.weight = aNumber;
    anEdge.name = aName;
    
    return anEdge;
}

+ (PESGraphEdge *)edgeWithName:(NSString *)aName {

    PESGraphEdge *anEdge = [[PESGraphEdge alloc] init];
    
    anEdge.name = aName;
    
    return anEdge;
}

#pragma mark -
#pragma mark Initilizers

- (id)init
{
    self = [super init];

    if (self) {
        
        // Set the default weight of the edge to be 1
        self.weight = [NSNumber numberWithInt:1];
    }
    
    return self;
}

#pragma mark -
#pragma mark Overrides

- (NSString *)description {
    
    return [NSString stringWithFormat:@"Edge: %@ with Weight:%@", self.name, self.weight];
}

#pragma mark -
#pragma mark Memory Management

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    PESGraphEdge *anotherEdge = [[PESGraphEdge allocWithZone:zone] init];
    anotherEdge.name = [name copy];
    anotherEdge.weight = [weight copy];
    
    return anotherEdge;
}

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.weight forKey:@"weight"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.weight = [coder decodeObjectForKey:@"weight"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    
    return self;
}
@end
