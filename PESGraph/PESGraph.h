//
//  PESGraph.h
//  PESGraph
//
//  Created by Peter Snyder on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PESGraphEdge, PESGraphNode, PESGraphRoute;

/**
	Class that depicts a set of nodes and the relationship between then (edges).  Also
    allows for calculating the quickest distance between two points in the graph
 */
@interface PESGraph : NSObject {
    
    /**
    	A collection of PESGraphNodes managed by the graph.  Keys will be identifiers for
        each node in the graph, with coresponding values also being NSMutableDictionaries.
        The keys in each sub NSMutableDictionary will then also be identifiers for nodes, 
        with those coresponding values being PESGraphEdge objects
     */
    NSMutableDictionary *nodeEdges;
    
    /**
        A collection of all nodes included in the graph
     */
    NSMutableDictionary *nodes;
}

@property (nonatomic, readonly) NSDictionary *nodes;

/**
    Returns a count of the number of edges currently in the graph.  Bi-directional edges are counted
    as two edges, for this count
    @returns an integer, >= 0, counting the number of edges in the graph.
 */
- (NSInteger)edgeCount;

/**
	Returns a node in the graph with the given unique identifier, or nil if no such node exists
	@param anIdentifier a string identifier coresponding to the indentifier property of a node
        in the graph
	@returns Either nil or the node with the given identifier
 */
- (PESGraphNode *)nodeInGraphWithIdentifier:(NSString *)anIdentifier;

/**
    Returns an edge object describing the edge from the given node to the destination node.  If no
    such edge exists, returns nil
    @param sourceNode the node to check the weight from
    @param destinationNode the node to check the weight to
    @returns either nil, or the edge object describing the connection from one node to the other
 */
- (PESGraphEdge *)edgeFromNode:(PESGraphNode *)sourceNode toNeighboringNode:(PESGraphNode *)destinationNode;

/**
	Returns the distance / weight from one node to another.  If either node is not
    found in the graph, or there is no edge from the source node to the destination node,
    nil is retuned.  This is a simple convenience wrapper around toNeighboringNode:
	@param sourceNode the node to check the weight from
	@param destinationNode the node to check the weight to
	@returns either nil, or a number object describing the weight from one node to the other
 */
- (NSNumber *)weightFromNode:(PESGraphNode *)sourceNode toNeighboringNode:(PESGraphNode *)destinationNode;

/**
	Returns an unordered collection of all nodes that receive edges from the given node.
	@param aNode a node to test for neighbors of
	@returns a set of zero or more other nodes.  Returns nil if aNode is not a member of the 
        graph
 */
- (NSSet *)neighborsOfNode:(PESGraphNode *)aNode;

/**
    Returns an unordered collection of all nodes that receive edges from the node identified
    by the given uniquely identifiying string.  This is just a conveninece wrapper around
    nodeInGraphWithIdentifier: and neighborsOfNode:
    @param aNodeIdentifier the unique identifier of one of the nodes in the graph
    @returns a set of zero or more other nodes.  Returns nil if no node in the graph is identified by
        aNodeIdentifier
 */
- (NSSet *)neighborsOfNodeWithIdentifier:(NSString *)aNodeIdentifier;

/**
	Adds a directional, weighted edge between two nodes in the graph.  If any provided nodes are not
        currently found in the graph, they're added
	@param anEdge the edge describing the connection between the two nodes
	@param aNode the node that the edge travels from
	@param anotherNode the node that the edge travels to
 */
- (void)addEdge:(PESGraphEdge *)anEdge fromNode:(PESGraphNode *)aNode toNode:(PESGraphNode *)anotherNode;

/**
    Removes a directional, weighted edge between two nodes in the graph.  If the edge does not exist, the 
    method does nothing.
    @param aNode the node that the edge travels from
    @param anotherNode the node that the edge travels to
    @returns a boolean description of whether an edge was removed
 */
- (BOOL)removeEdgeFromNode:(PESGraphNode*)aNode toNode:(PESGraphNode*)anotherNode;

/**
    Adds a weighted edge that travels in both directions from the two given nodes in the graph.  If any
        provided nodes are not currently found in the graph, they're added to the collection
    @param anEdge the edge describing the connection between the two nodes
    @param aNode one of the two nodes on one side of the edge
 	@param anotherNode the other of the two nodes on the other side of the edge
 */
- (void)addBiDirectionalEdge:(PESGraphEdge *)anEdge fromNode:(PESGraphNode *)aNode toNode:(PESGraphNode *)anotherNode;

/**
    Removes a bi-directional, weighted edge between two nodes in the graph.  If either edge does not exist, the 
    method does nothing.
    @param aNode the node that the edge travels from
    @param anotherNode the node that the edge travels to
    @returns a boolean description of whether a bi-directional edge was removed 
 */
- (BOOL)removeBiDirectionalEdgeFromNode:(PESGraphNode*)aNode toNode:(PESGraphNode*)anotherNode;

/**
	Returns a route object that describes the quickest path between the two given nodes.  If no route
	is possible, or either of the given start or end nodes are not in the graph, returns nil.
	@param startNode a node in the graph to begin calculating a path from
	@param endNode a node in graph to calculate a route to
	@returns either a PESGraphRoute object or nil, if no route is possible
 */
- (PESGraphRoute *)shortestRouteFromNode:(PESGraphNode *)startNode toNode:(PESGraphNode *)endNode;


#pragma mark -
#pragma mark "Private" methods

/**
	Used internally to find the smallest, non-infitiy value from values in the dictionary that corespond to
    keys in anArray, and return the coresponding key.  Returns nil if no such value exists
	@param aDictionary a dictionary of NSNumbers
    @param anArray a subset of keys in the dictionary to test.
	@returns the key that coresponds to the smallest, non infinity value in the dictionary, or else nil
 */
- (id)keyOfSmallestValue:(NSDictionary *)aDictionary withInKeys:(NSArray *)anArray;


@end