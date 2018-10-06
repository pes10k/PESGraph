//
//  PESNode.m
//  PESGraph
//
//  Created by Peter Snyder on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PESGraphNode.h"

@implementation PESGraphNode

@synthesize identifier;
@synthesize title;
@synthesize additionalData;


+ (PESGraphNode *)nodeWithIdentifier:(NSString *)anIdentifier {

    PESGraphNode *aNode = [[PESGraphNode alloc] init];
    
    aNode.identifier = anIdentifier;
    
    return aNode;
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    PESGraphNode *anotherNode = [[PESGraphNode allocWithZone:zone] init];
    anotherNode.identifier = [identifier copy];
    anotherNode.title = [identifier copy];
    anotherNode.additionalData = [additionalData mutableCopy];
    
    return anotherNode;
}

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.additionalData forKey:@"additionalData"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.identifier = [coder decodeObjectForKey:@"identifier"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.additionalData = [coder decodeObjectForKey:@"additionalData"];
    }
    
    return self;
}

@end
