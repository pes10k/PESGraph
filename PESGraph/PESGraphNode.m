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

    PESGraphNode *aNode = [[[PESGraphNode alloc] init] autorelease];
    
    aNode.identifier = anIdentifier;
    
    return aNode;
}

- (void)dealloc {
    [identifier release];
    [title release];
    [additionalData release];
    [super dealloc];
}

@end
