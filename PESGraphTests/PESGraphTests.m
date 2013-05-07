//
//  PESGraphTests.m
//  PESGraphTests
//
//  Created by Peter Snyder on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "PESGraphTests.h"
#import "PESGraph.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"
#import "PESGraphRoute.h"

@implementation PESGraphTests

// Basic test to make sure we can keep track of all nodes in the graph
- (void)testAddingNodes
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    // Create four basic nodes, connect them, add them to the graph, 
    // and make sure the graph contains them all.
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];

    [graph addEdge:[PESGraphEdge edgeWithName:@"A-B"] fromNode:aNode toNode:bNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"B-D"] fromNode:bNode toNode:dNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"C-D"] fromNode:cNode toNode:dNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"A-C"] fromNode:aNode toNode:cNode];
    
    STAssertEquals([NSNumber numberWithInt:4], [NSNumber numberWithInt:graph.nodes.count], @"Bad Amount, graph should contain 4 elements, not %d", graph.nodes.count);
    
}

// Test to make sure that edges are managed in the graph correctly.  The test graph below 
// looks like this (all edges are bi-directional)
//
//  A - 4 - B
//  |       |
//  3       6
//  |       |
//  C - 2 - D - 1 - F
//
- (void)testBiDirectionalEdges
{
    PESGraph *graph = [[PESGraph alloc] init];

    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *fNode = [PESGraphNode nodeWithIdentifier:@"F"];
    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-C" andWeight:[NSNumber numberWithInt:4]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-B" andWeight:[NSNumber numberWithInt:3]] fromNode:aNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C-D" andWeight:[NSNumber numberWithInt:2]] fromNode:cNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B-D" andWeight:[NSNumber numberWithInt:6]] fromNode:bNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D-F" andWeight:[NSNumber numberWithInt:1]] fromNode:dNode toNode:fNode];

    // Now check to make sure those weights are still as we expect them to be
    STAssertEquals([NSNumber numberWithInt:2], [graph weightFromNode:cNode toNeighboringNode:dNode], @"Invald weight from c -> d, should be 2, not %@", [graph weightFromNode:cNode toNeighboringNode:dNode]);

    STAssertEquals([NSNumber numberWithInt:4], [graph weightFromNode:aNode toNeighboringNode:bNode], @"Invald weight from a -> b, should be 4, not %@", [graph weightFromNode:aNode toNeighboringNode:bNode]);

    STAssertEquals([NSNumber numberWithInt:6], [graph weightFromNode:bNode toNeighboringNode:dNode], @"Invald weight from b -> d, should be 6, not %@", [graph weightFromNode:bNode toNeighboringNode:dNode]);

    
    // Also make sure they're correctly pointing both ways
    STAssertEquals([NSNumber numberWithInt:2], [graph weightFromNode:dNode toNeighboringNode:cNode], @"Invald weight from d -> c, should be 2, not %@", [graph weightFromNode:dNode toNeighboringNode:cNode]);

    // Last, make sure that nodes w/ no connection correctly report as nil
    STAssertNil([graph weightFromNode:aNode toNeighboringNode:fNode], @"Invald weight from a -> f, should be %@, not %@", nil, [graph weightFromNode:aNode toNeighboringNode:fNode]);

}

// Test to make sure edges are manage correctly when they're one directional
// Test graph looks like this
//   A -- 4 --> B -- 2 --> C <-- 3 --> D
//   ^                                 |
//    \------------- 10 ---------------/
//
- (void)testUniDirectionalEdges
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];

    [graph addEdge:[PESGraphEdge edgeWithName:@"A -> B" andWeight:[NSNumber numberWithInt:4]] fromNode:aNode toNode:bNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"B -> C" andWeight:[NSNumber numberWithInt:2]] fromNode:bNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> D" andWeight:[NSNumber numberWithInt:3]] fromNode:cNode toNode:dNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"D -> A" andWeight:[NSNumber numberWithInt:10]] fromNode:dNode toNode:aNode];

    // Now check that the edges all line up
    NSNumber *aToBWeight = [graph weightFromNode:aNode toNeighboringNode:bNode];    
    STAssertEquals([NSNumber numberWithInt:4], aToBWeight, @"Invald weight from a -> b, should be 4, not %@", aToBWeight);

    NSNumber *cToDWeight = [graph weightFromNode:cNode toNeighboringNode:dNode];    
    STAssertEquals([NSNumber numberWithInt:3], cToDWeight, @"Invald weight from c -> d, should be 3, not %@", cToDWeight);

    NSNumber *dToCWeight = [graph weightFromNode:dNode toNeighboringNode:cNode];    
    STAssertEquals([NSNumber numberWithInt:3], cToDWeight, @"Invald weight from d -> c, should be 3, not %@", dToCWeight);

    NSNumber *dToAWeight = [graph weightFromNode:dNode toNeighboringNode:aNode];    
    STAssertEquals([NSNumber numberWithInt:10], dToAWeight, @"Invald weight from d -> a, should be 10, not %@", dToAWeight);
    
    STAssertNil([graph weightFromNode:aNode toNeighboringNode:dNode], @"Invald weight from a -> d, should be %@, not %@", nil, [graph weightFromNode:aNode toNeighboringNode:dNode]);

    
}

// Test to make sure that nodes are correctly stored and relatable to their neighbors
// test graph looks like below (all edges are bi-directional)
//
//  A - 4 - B
//  |       |
//  3       6
//  |       |
//  C - 2 - D - 1 - F
//
- (void)testNeighboringNodes
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *fNode = [PESGraphNode nodeWithIdentifier:@"F"];
    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-C" andWeight:[NSNumber numberWithInt:4]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-B" andWeight:[NSNumber numberWithInt:3]] fromNode:aNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C-D" andWeight:[NSNumber numberWithInt:2]] fromNode:cNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B-D" andWeight:[NSNumber numberWithInt:6]] fromNode:bNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D-F" andWeight:[NSNumber numberWithInt:1]] fromNode:dNode toNode:fNode];

    NSSet *neighborsOfA = [graph neighborsOfNode:aNode];
    STAssertTrue([neighborsOfA containsObject:bNode], @"Incorrect Neighbors.  Node B should be a neighbor of A");
    STAssertTrue([neighborsOfA containsObject:cNode], @"Incorrect Neighbors.  Node C should be a neighbor of A");
    STAssertFalse([neighborsOfA containsObject:fNode], @"Incorrect Neighbors.  Node F should not be a neighbor of A");    
    STAssertFalse([neighborsOfA containsObject:dNode], @"Incorrect Neighbors.  Node D should not be a neighbor of A");    

}

// Test the shortest path, to make sure we're correctly pulling out the shortest path between two nodes
// Graph here is identical to the one on the "Dijkstra's algorithm" wikipedia page
// http://en.wikipedia.org/wiki/Dijkstra's_algorithm
- (void)testShortestPath
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *eNode = [PESGraphNode nodeWithIdentifier:@"E"];
    PESGraphNode *fNode = [PESGraphNode nodeWithIdentifier:@"F"];
    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> B" andWeight:[NSNumber numberWithInt:7]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> C" andWeight:[NSNumber numberWithInt:9]] fromNode:aNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> F" andWeight:[NSNumber numberWithInt:14]] fromNode:aNode toNode:fNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> C" andWeight:[NSNumber numberWithInt:10]] fromNode:bNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> D" andWeight:[NSNumber numberWithInt:15]] fromNode:bNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> F" andWeight:[NSNumber numberWithInt:2]] fromNode:cNode toNode:fNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> D" andWeight:[NSNumber numberWithInt:11]] fromNode:cNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D <-> E" andWeight:[NSNumber numberWithInt:6]] fromNode:dNode toNode:eNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"E <-> F" andWeight:[NSNumber numberWithInt:9]] fromNode:eNode toNode:fNode];

    PESGraphRoute *route = [graph shortestRouteFromNode:aNode toNode:eNode];

    // There should be three steps in the route, from A -> C -> F -> E
    STAssertTrue(4 == [route count], @"Invald number of steps in route, should be 4, not %d", [route count]);
    STAssertEquals(aNode, [route startingNode], @"Invald starting point for route, should be node A, not %d", [[route startingNode] identifier]);
    STAssertEquals(eNode, [route endingNode], @"Invald starting point for route, should be node E, not %d", [[route endingNode] identifier]);
    STAssertTrue(20 == [route length], @"Invalid distance for route, should be 23, not %f.0", [route length]);
    
}

// A second test of the Dijkstra algorithm, here with the data on
// http://computer.howstuffworks.com/routing-algorithm3.htm
- (void)testShortestPathSecond
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *eNode = [PESGraphNode nodeWithIdentifier:@"E"];

    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> B" andWeight:[NSNumber numberWithInt:1]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> C" andWeight:[NSNumber numberWithInt:5]] fromNode:aNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> D" andWeight:[NSNumber numberWithInt:2]] fromNode:bNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> E" andWeight:[NSNumber numberWithInt:4]] fromNode:bNode toNode:eNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> D" andWeight:[NSNumber numberWithInt:2]] fromNode:cNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> E" andWeight:[NSNumber numberWithInt:3]] fromNode:cNode toNode:eNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D <-> E" andWeight:[NSNumber numberWithInt:1]] fromNode:dNode toNode:eNode];
    
    PESGraphRoute *route = [graph shortestRouteFromNode:aNode toNode:eNode];

    // There should be four steps in the route, from A -> B -> D -> E
    STAssertTrue(4 == [route count], @"Invald number of steps in route, should be 4, not %d", [route count]);
    STAssertEquals(aNode, [route startingNode], @"Invald starting point for route, should be node A, not %d", [[route startingNode] identifier]);
    STAssertEquals(eNode, [route endingNode], @"Invald starting point for route, should be node E, not %d", [[route endingNode] identifier]);
    STAssertTrue(4 == [route length], @"Invalid distance for route, should be 4, not %f.0", [route length]);
    
}

// A third test of the Dijkstra algorithm implementation, with the data taken from
// http://www.math.unm.edu/~loring/links/graph_s09/dijskstra3.pdf (first problem)
- (void)testShortestPathThird
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *oNode = [PESGraphNode nodeWithIdentifier:@"O"];
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *eNode = [PESGraphNode nodeWithIdentifier:@"E"];
    PESGraphNode *fNode = [PESGraphNode nodeWithIdentifier:@"F"];
    PESGraphNode *gNode = [PESGraphNode nodeWithIdentifier:@"G"];
    PESGraphNode *hNode = [PESGraphNode nodeWithIdentifier:@"H"];
    PESGraphNode *iNode = [PESGraphNode nodeWithIdentifier:@"I"];
    PESGraphNode *tNode = [PESGraphNode nodeWithIdentifier:@"T"];
    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"O <-> A" andWeight:[NSNumber numberWithInt:1]] fromNode:oNode toNode:aNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"O <-> D" andWeight:[NSNumber numberWithInt:1]] fromNode:oNode toNode:dNode];    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> B" andWeight:[NSNumber numberWithInt:2]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A <-> T" andWeight:[NSNumber numberWithInt:9]] fromNode:aNode toNode:tNode];    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> C" andWeight:[NSNumber numberWithInt:2]] fromNode:bNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B <-> F" andWeight:[NSNumber numberWithInt:2]] fromNode:bNode toNode:fNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C <-> E" andWeight:[NSNumber numberWithInt:1]] fromNode:cNode toNode:eNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D <-> G" andWeight:[NSNumber numberWithInt:1]] fromNode:dNode toNode:gNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"E <-> F" andWeight:[NSNumber numberWithInt:2]] fromNode:eNode toNode:fNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"E <-> I" andWeight:[NSNumber numberWithInt:2]] fromNode:eNode toNode:iNode];    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"F <-> H" andWeight:[NSNumber numberWithInt:1]] fromNode:fNode toNode:hNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"G <-> H" andWeight:[NSNumber numberWithInt:1]] fromNode:gNode toNode:hNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"I <-> T" andWeight:[NSNumber numberWithInt:1]] fromNode:iNode toNode:tNode];

    PESGraphRoute *route = [graph shortestRouteFromNode:oNode toNode:tNode];
    
    // There are two valid, equally weighted trips here, O -> A -> B -> C -> E -> I -> T and O -> D -> G -> H -> F -> E -> I -> T
    // Both have a total distance of 9
    STAssertTrue((7 == [route count] || 8 == [route count]), @"Invald number of steps in route, should be 7 or 8, not %d", [route count]);
    STAssertTrue(9 == [route length], @"Invalid distance for route, should be 9, not %f.0", [route length]);
    
}

// Test removing uni-directional edges from a graph
- (void)testRemoveEdgeFromNode
{
    PESGraph *graph = [[PESGraph alloc] init];

    // Create a simple graph with four nodes, and five several uni-directional edges
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    
    [graph addEdge:[PESGraphEdge edgeWithName:@"A -> B"] fromNode:aNode toNode:bNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"B -> D"] fromNode:bNode toNode:dNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"B -> A"] fromNode:bNode toNode:aNode];    
    [graph addEdge:[PESGraphEdge edgeWithName:@"C -> D"] fromNode:cNode toNode:dNode];
    [graph addEdge:[PESGraphEdge edgeWithName:@"A -> C"] fromNode:aNode toNode:cNode];
    
    STAssertEquals([NSNumber numberWithInt:4], [NSNumber numberWithInt:graph.nodes.count], @"Bad Amount, graph should contain 4 node, not %d", graph.nodes.count);
    STAssertEquals([NSNumber numberWithInt:5], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should contain 5 edges, not %d", [graph edgeCount]);

    // Also, specifically check that the edge we're interested in exists
    STAssertNotNil([graph edgeFromNode:bNode toNeighboringNode:dNode], @"An edge from B -> D should exist in the graph");
    
    // Now, remove a couple of edges and make sure that the graph is updated accordingly     
    STAssertEquals([graph removeEdgeFromNode:bNode toNode:dNode], YES, @"Removing an existing node should return YES");
    
    // Should now be 4 edges remaining in the graph
    STAssertEquals([NSNumber numberWithInt:4], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 4 edges, not %d", [graph edgeCount]);
    
    // Also make sure that there is no longer a edge between these two node
    STAssertNil([graph edgeFromNode:bNode toNeighboringNode:dNode], @"An edge from B -> D should exist in the graph");
    
    // Do it all again, by removing the edge from A -> C
    STAssertNotNil([graph edgeFromNode:aNode toNeighboringNode:cNode], @"An edge from A -> C should exist in the graph");
    STAssertEquals([graph removeEdgeFromNode:aNode toNode:cNode], YES, @"Removing an existing node should return YES");
    STAssertEquals([NSNumber numberWithInt:3], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 3 edges, not %d", [graph edgeCount]);
    STAssertNil([graph edgeFromNode:aNode toNeighboringNode:cNode], @"An edge from A -> C should exist in the graph");
    
    // Next, make sure we can add the edge back in and have everything update correctly
    [graph addEdge:[PESGraphEdge edgeWithName:@"A -> C"] fromNode:aNode toNode:cNode];
    STAssertEquals([NSNumber numberWithInt:4], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 4 edges, not %d", [graph edgeCount]);
    STAssertNotNil([graph edgeFromNode:aNode toNeighboringNode:cNode], @"An edge from A -> C should exist in the graph");
        
    // Last, check and make sure that we fail when we try to remove a non-existant edge
    STAssertEquals([graph removeEdgeFromNode:aNode toNode:dNode], NO, @"Trying to remove a non-existant edge should return NO");
}

- (void)testRemoveBiDirectionalEdgeFromNode
{
    PESGraph *graph = [[PESGraph alloc] init];
    
    PESGraphNode *aNode = [PESGraphNode nodeWithIdentifier:@"A"];
    PESGraphNode *bNode = [PESGraphNode nodeWithIdentifier:@"B"];
    PESGraphNode *cNode = [PESGraphNode nodeWithIdentifier:@"C"];
    PESGraphNode *dNode = [PESGraphNode nodeWithIdentifier:@"D"];
    PESGraphNode *fNode = [PESGraphNode nodeWithIdentifier:@"F"];
    
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-C" andWeight:[NSNumber numberWithInt:4]] fromNode:aNode toNode:bNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"A-B" andWeight:[NSNumber numberWithInt:3]] fromNode:aNode toNode:cNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"C-D" andWeight:[NSNumber numberWithInt:2]] fromNode:cNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"B-D" andWeight:[NSNumber numberWithInt:6]] fromNode:bNode toNode:dNode];
    [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:@"D-F" andWeight:[NSNumber numberWithInt:1]] fromNode:dNode toNode:fNode];

    // Basic sanity check to make sure the graph looks how we expect
    STAssertEquals([NSNumber numberWithInt:5], [NSNumber numberWithInt:graph.nodes.count], @"Bad Amount, graph should contain 4 node, not %d", graph.nodes.count);
    STAssertEquals([NSNumber numberWithInt:10], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should contain 10 edges, not %d", [graph edgeCount]);

    // Now, try removing an exisitng bi-directional edge
    STAssertEquals([graph removeBiDirectionalEdgeFromNode:aNode toNode:cNode], YES, @"should be able to correctly remove an exiting bi-directional edge");
    
    // Now check to make sure that the counts are still correct
    STAssertEquals([NSNumber numberWithInt:5], [NSNumber numberWithInt:graph.nodes.count], @"Bad Amount, graph should contain 4 node, not %d", graph.nodes.count);
    STAssertEquals([NSNumber numberWithInt:8], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should contain 8 edges, not %d", [graph edgeCount]);

    // Now try to remove a non-existing bi-directional edge and make sure it fails
    STAssertEquals([graph removeBiDirectionalEdgeFromNode:aNode toNode:fNode], NO, @"There is no edge from A <-> F, so removing shoudl fail");
 
    // Check to make sure we _really_ didn't remove anything by looking at the counts too
    STAssertEquals([NSNumber numberWithInt:5], [NSNumber numberWithInt:graph.nodes.count], @"Bad Amount, graph should still contain 4 node, not %d", graph.nodes.count);
    STAssertEquals([NSNumber numberWithInt:8], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should still contain 8 edges, not %d", [graph edgeCount]);

    // Now, remove a single edge (ie just half of an origianlly added bi-directional edge)
    STAssertEquals([graph removeEdgeFromNode:dNode toNode:cNode], YES, @"Should be able to successfully remove a single edge of an (originally) bi-direcitonal edge");
    STAssertEquals([NSNumber numberWithInt:7], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 7 edges, not %d", [graph edgeCount]);
    
    // Next, make sure trying to remove a bi-directional edge, where one direction of the edge has already been removed, fails
    STAssertEquals([graph removeBiDirectionalEdgeFromNode:dNode toNode:cNode], NO, @"There edge from c -> d is no longer bi-directional, so this should fail");
    
    // Since we didn't actually remove anything above, we should still have 7 edges in the graph
    STAssertEquals([NSNumber numberWithInt:7], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 7 edges, not %d", [graph edgeCount]);

    // Last, make sure we can remove a bi-directional edge, even when we try to remove them in the opposite order we declaried them (ie removing
    // D <-> F should have the same effect as removing F <-> D
    STAssertEquals([graph removeBiDirectionalEdgeFromNode:fNode toNode:dNode], YES, @"We should be able to remove the bi-directional edge between two nodes, regardless of node order");
    STAssertEquals([NSNumber numberWithInt:5], [NSNumber numberWithInt:[graph edgeCount]], @"Bad Amount, graph should now contain 5 edges, not %d", [graph edgeCount]);
}


@end
