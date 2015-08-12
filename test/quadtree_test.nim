import unittest, quadtree

suite "Quadtrees should":

    type Box = tuple[x, y, width, height: float]

    proc boundingBox( b: Box ): BoundingBox =
        (top: b.y, left: b.x, width: b.width, height: b.height)


    test "Return an empty seq when fetching from an empty quadtree":
        let tree = newQuadtree[Box]()
        require( tree.fetch(0, 0) == @[] )
