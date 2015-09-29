import unittest, quadtree, options


type
    Box = tuple[left, top, width, height: int]

proc boundingBox*( b: Box ): BoundingBox =
    return ( y: b.top, x: b.left, width: b.width, height: b.height )

proc contains*( bound: Square, elem: Box ): bool =
    if bound.x + bound.size < elem.left: return false
    if bound.x > elem.left + elem.width: return false
    if bound.y + bound.size < elem.top: return false
    if bound.y > elem.top + elem.height: return false
    return true


suite "Quadtrees with custom BoundingBox procs should":

    test "Use the boundingBox method to get dimensions":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        let box1: Box = (left: 0, top: 0, width: 4, height: 4)
        let box2: Box = (left: 10, top: 1, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: -1, x: -1, size: 16))
        require( tree.fetch(1, 1) == @[ box1 ] )
        require( tree.fetch(11, 1) == @[ box2 ] )


