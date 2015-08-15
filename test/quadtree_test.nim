import unittest, quadtree


type Box = tuple[x, y, width, height: int]

proc boundingBox*( b: Box ): BoundingBox =
    return (
        top: float(b.y),
        left: float(b.x),
        width: float(b.width),
        height: float(b.height)
    )

proc contains*( bounding: BoundingBox, elem: Box ): bool = false


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
