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
