import unittest, quadtree


type Box = tuple[x, y, width, height: int]

proc boundingBox*( b: Box ): BoundingBox =
    return ( top: b.y, left: b.x, width: b.width, height: b.height )

proc contains*( bound: BoundingBox, elem: Box ): bool =
    if bound.left + bound.width < elem.x: return false
    if bound.left > elem.x + elem.width: return false
    if bound.top + bound.height < elem.y: return false
    if bound.top > elem.y + elem.height: return false
    return true


suite "Quadtrees should":

    test "Return an empty seq when fetching from an empty quadtree":
        let tree = newQuadtree[Box]()
        require( tree.fetch(0, 0) == @[] )

    test "Add and fetch a single bounding box":
        var tree = newQuadtree[Box]()
        let box: Box = (x: 0, y: 0, width: 5, height: 5)
        tree.insert( box )
        require( tree.fetch(0, 0) == @[ box ] )

    test "Adding to a tree without expanding":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        let box1 = (x: 4, y: 4, width: 5, height: 5)
        let box2 = (x: 1, y: 1, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require( tree.fetch(3, 3) == @[ box1, box2 ] )

    test "Convert to a string":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        discard $tree

    test "Subdividing a leaf node after it gets full":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        let box1 = (x: 0, y: 0, width: 4, height: 4)
        let box2 = (x: 10, y: 1, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require( tree.fetch(1, 1) == @[ box1 ] )
        require( tree.fetch(11, 1) == @[ box2 ] )

