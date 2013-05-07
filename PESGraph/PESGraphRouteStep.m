//
//  PESGraphRouteStep.m
//  PESGraph
//
//  Created by Peter Snyder on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PESGraphRouteStep.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"

@implementation PESGraphRouteStep

@synthesize node, edge, isBeginningStep, isEndingStep;

#pragma mark -
#pragma mark Initilizers

- (id)init
{
    self = [super init];

    if (self) {
        
        isBeginningStep = NO;
        isEndingStep = NO;
    }
    
    return self;
}

- (id)initWithNode:(PESGraphNode *)aNode andEdge:(PESGraphEdge *)anEdge
{    
    self = [super init];
    
    if (self) {
        
        isBeginningStep = NO;
        isEndingStep = (anEdge == nil);
        node = aNode;
        edge = anEdge;
    }
    
    return self;
}

- (id)initWithNode:(PESGraphNode *)aNode andEdge:(PESGraphEdge *)anEdge asBeginning:(bool)isBeginning
{    
    self = [super init];
    
    if (self) {
        
        isBeginningStep = isBeginning;
        isEndingStep = (anEdge == nil);
        node = aNode;
        edge = anEdge;
    }
    
    return self;
}

#pragma mark -
#pragma mark Property Implementations
- (bool)isEndingStep
{
    return (self.edge == nil);
}

#pragma mark -
#pragma mark Memory Management


@end
