//
//  PESGraph.m
//  PESGraph
//
//  Created by Peter Snyder on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PESGraph.h"
#import "PESGraphEdge.h"
#import "PESGraphNode.h"
#import "PESGraphRoute.h"

@implementation PESGraph

@synthesize nodes;

- (id)init
{
    self = [super init];

    if (self) {

        nodeEdges = [[NSMutableDictionary alloc] init];
        nodes = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (PESGraphNode *)nodeInGraphWithIdentifier:(NSString *)anIdentifier
{
    return [nodes objectForKey:anIdentifier];
}

- (PESGraphEdge *)edgeFromNode:(PESGraphNode *)sourceNode toNeighboringNode:(PESGraphNode *)destinationNode
{
    // First check to make sure a node with the identifier of the given source node exists in the graph
    if ( ! [nodeEdges objectForKey:sourceNode.identifier]) {

        return nil;
        
    } else {
        
        // Next, make sure that there is an edge from the from the given node to the destination node.  If
        // so, return it.  Otherwise, fall back on the returned nil
        return [[nodeEdges objectForKey:sourceNode.identifier] objectForKey:destinationNode.identifier];
    }
}

- (NSNumber *)weightFromNode:(PESGraphNode *)sourceNode toNeighboringNode:(PESGraphNode *)destinationNode
{
    PESGraphEdge *graphEdge = [self edgeFromNode:sourceNode toNeighboringNode:destinationNode];

    return (graphEdge) ? graphEdge.weight : nil;
}

- (NSInteger)edgeCount
{
    NSInteger edgeCount = 0;
    
    for (NSString *nodeIdentifier in nodeEdges) {
        
        edgeCount += [(NSDictionary *)[nodeEdges objectForKey:nodeIdentifier] count];        
    }
    
    return edgeCount;
}

- (NSSet *)neighborsOfNode:(PESGraphNode *)aNode
{
    NSDictionary *edgesFromNode = [nodeEdges objectForKey:aNode.identifier];
    
    // If we don't have any record of the given node in the collection, determined by its identifier,
    // return nil
    if (edgesFromNode == nil) {
        
        return nil;
        
    } else {
        
        NSMutableSet *neighboringNodes = [NSMutableSet set];

        // Otherwise, iterate over all the keys (identifiers) of nodes receiving edges
        // from the given node, retreive their coresponding node object, add it to the
        // set, and return the completed set
        for (NSString *neighboringNodeIdentifier in edgesFromNode) {
            
            [neighboringNodes addObject:[nodes objectForKey:neighboringNodeIdentifier]];
        }
        
        return neighboringNodes;
    }
}

- (NSSet *)neighborsOfNodeWithIdentifier:(NSString *)aNodeIdentifier
{    
    PESGraphNode *identifiedNode = [nodes objectForKey:aNodeIdentifier];
    
    return (identifiedNode == nil) ? nil : [self neighborsOfNode:identifiedNode];    
}


- (void)addEdge:(PESGraphEdge *)anEdge fromNode:(PESGraphNode *)aNode toNode:(PESGraphNode *)anotherNode
{
    [nodes setObject:aNode forKey:aNode.identifier];
    [nodes setObject:anotherNode forKey:anotherNode.identifier];

    // If we don't have any edges leaving from from the given node (aNode),
    // create a new record in the node dictionary.  Otherwise just add the new edge / connection to the
    // collection
    if ([nodeEdges objectForKey:aNode.identifier] == nil) {

        [nodeEdges setObject:[NSMutableDictionary dictionaryWithObject:anEdge
                                                                forKey:anotherNode.identifier]
                      forKey:aNode.identifier];

    } else {
        
        [(NSMutableDictionary *)[nodeEdges objectForKey:aNode.identifier] setObject:anEdge
                                                                             forKey:anotherNode.identifier];

    }
}

- (BOOL)removeEdgeFromNode:(PESGraphNode*)aNode toNode:(PESGraphNode*)anotherNode 
{  
    // Check to see if the edge exists.  No such edge exists, return false and do nothing
    if ([[nodeEdges objectForKey:aNode.identifier] objectForKey:anotherNode.identifier] == nil) {

        return NO;
    
    } else {
             
        // Otherwise, remove the relevant edge and return YES
        [[nodeEdges objectForKey:aNode.identifier] removeObjectForKey:anotherNode.identifier];
        return YES;
    }    
}

- (void)addBiDirectionalEdge:(PESGraphEdge *)anEdge fromNode:(PESGraphNode *)aNode toNode:(PESGraphNode *)anotherNode
{    
    [self addEdge:anEdge fromNode:aNode toNode:anotherNode];
    [self addEdge:anEdge fromNode:anotherNode toNode:aNode];    
}

- (BOOL)removeBiDirectionalEdgeFromNode:(PESGraphNode*)aNode toNode:(PESGraphNode*)anotherNode 
{
    // First, make sure edges exist in both directions.  If they don't, return NO and do nothing
    PESGraphEdge *toEdge = [self edgeFromNode:aNode toNeighboringNode:anotherNode];
    PESGraphEdge *fromEdge = [self edgeFromNode:anotherNode toNeighboringNode:aNode];
    
    if (toEdge == nil || fromEdge == nil) {
        
        return NO;
        
    } else {
        
        [self removeEdgeFromNode:aNode toNode:anotherNode];
        [self removeEdgeFromNode:anotherNode toNode:aNode];
        return YES;

    }
}

// Returns the quickest possible path between two nodes, using Dijkstra's algorithm
// http://en.wikipedia.org/wiki/Dijkstra's_algorithm
- (PESGraphRoute *)shortestRouteFromNode:(PESGraphNode *)startNode toNode:(PESGraphNode *)endNode
{
    NSMutableDictionary *unexaminedNodes = [NSMutableDictionary dictionaryWithDictionary:self.nodes];

    // The shortest yet found distance to the origin for each node in the graph.  If we haven't
    // yet found a path back to the origin from a node, or if there isn't one, mark with -1 
    // (which is used equivlently to how infinity is used in some Dijkstra implementations)
    NSMutableDictionary *distancesFromSource = [NSMutableDictionary dictionaryWithCapacity:[unexaminedNodes count]];
    
    // A collection that stores the previous node in the quickest path back to the origin for each
    // examined node in the graph (so you can retrace the fastest path from any examined node back
    // looking up the value that coresponds to any node identifier.  That value will be the previous
    // node in the path
    NSMutableDictionary *previousNodeInOptimalPath = [NSMutableDictionary dictionaryWithCapacity:[unexaminedNodes count]];

    // Since NSNumber doesn't have a state for infinitiy, but since we know that all weights have to be
    // positive, we can treat -1 as infinity
    NSNumber *infinity = [NSNumber numberWithInt:-1];

    // Set every node to be infinitely far from the origin (ie no path back has been found yet).
    for (NSString *nodeIdentifier in unexaminedNodes) {
        
        [distancesFromSource setValue:infinity
                               forKey:nodeIdentifier];
    }

    // Set the distance from the source to itself to be zero
    [distancesFromSource setValue:[NSNumber numberWithInt:0]
                           forKey:startNode.identifier];

    NSString *currentlyExaminedIdentifier = nil;

    while ([unexaminedNodes count] > 0) {

        // Find the node, of all the unexamined nodes, that we know has the closest path back to the origin
        NSString *identifierOfSmallestDist = [self keyOfSmallestValue:distancesFromSource withInKeys:[unexaminedNodes allKeys]];

        // If we failed to find any remaining nodes in the graph that are reachable from the source,
        // stop processing
        if (identifierOfSmallestDist == nil) {

            break;            
        
        } else {

            PESGraphNode *nodeMostRecentlyExamined = [self nodeInGraphWithIdentifier:identifierOfSmallestDist];
            
            // If the next closest node to the origin is the target node, we don't need to consider any more
            // possibilities, we've already hit the shortest distance!  So, we can remove all other 
            // options from consideration.
            if ([identifierOfSmallestDist isEqualToString:endNode.identifier]) {

                currentlyExaminedIdentifier = endNode.identifier;
                break;

            } else {

                // Otherwise, remove the node thats the closest to the source and continue the search by looking
                // for the next closest item to the orgin. 
                [unexaminedNodes removeObjectForKey:identifierOfSmallestDist];
                
                // Now, iterate over all the nodes that touch the one closest to the graph
                for (PESGraphNode *neighboringNode in [self neighborsOfNodeWithIdentifier:identifierOfSmallestDist]) {
                    
                    // Calculate the distance to the origin, from the neighboring node, through the most recently
                    // examined node.  If its less than the shortest path we've found from the neighboring node
                    // to the origin so far, save / store the new shortest path amount for the node, and set
                    // the currently being examined node to be the optimal path home
                    // The distance of going from the neighbor node to the origin, going through the node we're about to eliminate
                    NSNumber *alt = [NSNumber numberWithFloat:
                                     [[distancesFromSource objectForKey:identifierOfSmallestDist] floatValue] +
                                     [[self weightFromNode:nodeMostRecentlyExamined toNeighboringNode:neighboringNode] floatValue]];
                    
                    NSNumber *distanceFromNeighborToOrigin = [distancesFromSource objectForKey:neighboringNode.identifier];

                    // If its quicker to get to the neighboring node going through the node we're about the remove 
                    // than through any other path, record that the node we're about to remove is the current fastes
                    if ([distanceFromNeighborToOrigin isEqualToNumber:infinity] || [alt compare:distanceFromNeighborToOrigin] == NSOrderedAscending) {

                        [distancesFromSource setValue:alt forKey:neighboringNode.identifier];
                        [previousNodeInOptimalPath setValue:nodeMostRecentlyExamined forKey:neighboringNode.identifier];
                    }
                }                
            }
        }
    }

    // There are two situations that cause the above loop to exit,
    // 1. We've found a path between the origin and the destination node, or
    // 2. there are no more possible routes to consider to the destination, in which case no possible
    // solution / route exists.
    //
    // If the key of the destination node is equal to the node we most recently found to be in the shortest path 
    // between the origin and the destination, we're in situation 2.  Otherwise, we're in situation 1 and we
    // should just return nil and be done with it
    if ( currentlyExaminedIdentifier == nil || ! [currentlyExaminedIdentifier isEqualToString:endNode.identifier]) {
        
        return nil;
        
    } else {
        
        // If we did successfully find a path, create and populate a route object, describing each step
        // of the path.
        PESGraphRoute *route = [[PESGraphRoute alloc] init];
        
        // We do this by first building the route backwards, so the below array with have the last step
        // in the route (the destination) in the 0th position, and the origin in the last position
        NSMutableArray *nodesInRouteInReverseOrder = [NSMutableArray array];

        [nodesInRouteInReverseOrder addObject:endNode];
        
        PESGraphNode *lastStepNode = endNode;
        PESGraphNode *previousNode;
        
        while ((previousNode = [previousNodeInOptimalPath objectForKey:lastStepNode.identifier])) {
            
            [nodesInRouteInReverseOrder addObject:previousNode];
            lastStepNode = previousNode;
        }

        // Now, finally, at this point, we can reverse the array and build the complete route object, by stepping through 
        // the nodes and piecing them togheter with their routes
        NSUInteger numNodesInPath = [nodesInRouteInReverseOrder count];
        for (int i = (int)numNodesInPath - 1; i >= 0; i--) {
            
            PESGraphNode *currentGraphNode = [nodesInRouteInReverseOrder objectAtIndex:i];
            PESGraphNode *nextGraphNode = (i - 1 < 0) ? nil : [nodesInRouteInReverseOrder objectAtIndex:(i - 1)];
            
            [route addStepFromNode:currentGraphNode withEdge:nextGraphNode ? [self edgeFromNode:currentGraphNode toNeighboringNode:nextGraphNode] : nil];
        }
        
        return route;
    }
}

- (id)keyOfSmallestValue:(NSDictionary *)aDictionary withInKeys:(NSArray *)anArray
{
    id keyForSmallestValue = nil;
    NSNumber *smallestValue = nil;
    
    NSNumber *infinity = [NSNumber numberWithInt:-1];
    
    for (id key in anArray) {

        // Check to see if we have or proxie for infinity here.  If so, ignore this value
        NSNumber *currentTestValue = [aDictionary objectForKey:key];

        if ( ! [currentTestValue isEqualToNumber:infinity]) {
                        
            if (smallestValue == nil || [smallestValue compare:currentTestValue] == NSOrderedDescending) {

                keyForSmallestValue = key;
                smallestValue = currentTestValue;
            }
        }
    }
    
    return keyForSmallestValue;
}

#pragma mark -
#pragma mark Memory Management


@end
