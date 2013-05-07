//
//  PESGraphRoute.m
//  PESGraph
//
//  Created by Peter Snyder on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PESGraphRoute.h"
#import "PESGraphRouteStep.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"

@implementation PESGraphRoute

@synthesize steps;

- (id)init
{
    self = [super init];

    if (self) {

        steps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addStepFromNode:(PESGraphNode *)aNode withEdge:(PESGraphEdge *)anEdge
{
    PESGraphRouteStep *aStep = [[PESGraphRouteStep alloc] initWithNode:aNode
                                                                andEdge:anEdge
                                                            asBeginning:([steps count] == 0)];
    
    [steps addObject:aStep];
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString string];
    
    [string appendString:@"Start: \n"];
    
    for (PESGraphRouteStep *aStep in steps) {
        
        if (aStep.edge) {

            [string appendFormat:@"\t%@ -> %@\n", aStep.node.identifier, aStep.edge];

        } else {
            
            [string appendFormat:@"\t%@ (End)", aStep.node.identifier];
            
        }
    }

    return string;
}

- (NSUInteger)count {
    
    return [steps count];    
}

- (PESGraphNode *)startingNode {
    
    return ([self count] > 0) ? [[steps objectAtIndex:0] node] : nil;
}

- (PESGraphNode *)endingNode {
    
    return ([self count] > 0) ? [[steps objectAtIndex:([self count] - 1)] node] : nil;
}

- (float)length {
    
    float totalLength = 0;
    
    for (PESGraphRouteStep *aStep in steps) {
        
        if (aStep.edge) {

            totalLength += [aStep.edge.weight floatValue];
        }
    }
 
    return totalLength;
}

#pragma mark -
#pragma mark Memory Management


@end
