import unittest, quadtree, options, math


type
    Box = tuple[left, top, size: int]
    Rectangle = tuple[x, y, width, height: int]

proc boundingBox*( b: Box ): tuple[y, x, width, height: int] =
    return ( y: b.top, x: b.left, width: b.size, height: b.size )


suite "Quadtrees with customizations should":

    test "Use the boundingBox method to get dimensions":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        let box1: Box = (left: 0, top: 0, size: 4)
        let box2: Box = (left: 10, top: 1, size: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: -1, x: -1, size: 16))
        require( tree.fetch(1, 1) == @[ box1 ] )
        require( tree.fetch(11, 1) == @[ box2 ] )

    test "Use the element itself as a bounding box":
        var tree = newQuadtree[Rectangle](maxInQuadrant = 1)
        let rect1: Rectangle = (x: 0,  y: 0, width: 4, height: 2)
        let rect2: Rectangle = (x: 10, y: 1, width: 2, height: 5)
        tree.insert( rect1 )
        tree.insert( rect2 )
        require(tree.bounds.get == (y: -1, x: -1, size: 16))
        require( tree.fetch(1, 1) == @[ rect1 ] )
        require( tree.fetch(11, 1) == @[ rect2 ] )


