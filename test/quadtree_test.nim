import unittest, quadtree, options


type
    Box = tuple[left, top, width, height: int]

    InvalidContains = object
        left, top, width, height: int

proc boundingBox*( b: Box|InvalidContains ): BoundingBox =
    return ( y: b.top, x: b.left, width: b.width, height: b.height )

proc contains*( bound: Square, elem: Box ): bool =
    if bound.x + bound.size < elem.left: return false
    if bound.x > elem.left + elem.width: return false
    if bound.y + bound.size < elem.top: return false
    if bound.y > elem.top + elem.height: return false
    return true

proc contains*( bound: Square, elem: InvalidContains ): bool = false


suite "Quadtrees should":

    let empty: seq[Box] = @[]

    test "Return an empty seq when fetching from an empty quadtree":
        let tree = newQuadtree[Box]()
        require( tree.fetch(0, 0) == empty )

    test "Add and fetch a single bounding box":
        var tree = newQuadtree[Box]()
        let box: Box = (left: 0, top: 0, width: 5, height: 5)
        tree.insert( box )
        require(tree.bounds.get == (y: -1, x: -1, size: 32))
        require( tree.fetch(0, 0) == @[ box ] )

    test "Adding to a tree without subdividing":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        let box1: Box = (left: 1, top: 1, width: 5, height: 5)
        let box2: Box = (left: 4, top: 4, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: 0, x: 0, size: 32))
        require( tree.fetch(3, 3) == @[ box1, box2 ] )

    test "Convert to a string":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        discard $tree

    test "Subdividing a leaf node after it gets full":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        let box1: Box = (left: 0, top: 0, width: 4, height: 4)
        let box2: Box = (left: 10, top: 1, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: -1, x: -1, size: 16))
        require( tree.fetch(1, 1) == @[ box1 ] )
        require( tree.fetch(11, 1) == @[ box2 ] )

    test "Return the bouding box of a tree":
        var tree = newQuadtree[Box]()
        require( tree.bounds == none(Square) )
        tree.insert( (left: 10, top: 2, width: 2, height: 2) )
        require(tree.bounds.get == (y: 1, x: 9, size: 8))

    test "Expand the boundaries when adding an outside right element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        require(tree.bounds.get == (y: 4, x: 2, size: 8))

        tree.insert( (left: 10, top: 5, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside bottom element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: 5, top: 12, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside x element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: -3, top: 6, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside y element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: 4, top: -2, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding a tall element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: 4, top: 6, width: 2, height: 20) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding a wide element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: 4, top: 6, width: 20, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the until it fits the new element":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 3, top: 5, width: 2, height: 2) )
        tree.insert( (left: 90000, top: 6, width: 20, height: 2) )
        require(tree.bounds.get == (y: -174756, x: -174758, size: 524288))

    test "Allow the same element to be added many times":
        var tree = newQuadtree[Box]()
        tree.insert( (left: 0, top: 0, width: 1, height: 1) )
        tree.insert( (left: 0, top: 0, width: 1, height: 1) )
        tree.insert( (left: 0, top: 0, width: 1, height: 1) )
        tree.insert( (left: 0, top: 0, width: 1, height: 1) )
        tree.insert( (left: 0, top: 0, width: 1, height: 1) )

        require(tree.fetch(0, 0) == @[
            (left: 0, top: 0, width: 1, height: 1),
            (left: 0, top: 0, width: 1, height: 1),
            (left: 0, top: 0, width: 1, height: 1),
            (left: 0, top: 0, width: 1, height: 1),
            (left: 0, top: 0, width: 1, height: 1)
        ])

    test "Fetching from an empty quadrant":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (left: 1, top: 1, width: 3, height: 3) )
        tree.insert( (left: 2, top: 2, width: 2, height: 2) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(9, 0) == empty)
        require(tree.fetch(10, 10) == empty)
        require(tree.fetch(0, 11) == empty)

    test "Fetching from outside a tree with a single node tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (left: 1, top: 1, width: 3, height: 3) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(-5, 5) == empty)
        require(tree.fetch(5, -5) == empty)
        require(tree.fetch(5, 20) == empty)
        require(tree.fetch(20, 5) == empty)

    test "Fetching from outside a tree with a multi-node tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (left: 1, top: 1, width: 3, height: 3) )
        tree.insert( (left: 9, top: 9, width: 3, height: 3) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(-5, 5) == empty)
        require(tree.fetch(5, -5) == empty)
        require(tree.fetch(5, 20) == empty)
        require(tree.fetch(20, 5) == empty)

    test "Throw an error when an element isnt added to any quadrant":
        var tree = newQuadtree[InvalidContains](maxInQuadrant = 1)
        tree.insert( InvalidContains(left: 1, top: 1, width: 3, height: 3) )
        expect(AssertionError):
            tree.insert( InvalidContains(left: 9, top: 9, width: 3, height: 3) )

    test "Disallow negative widths and heights on a bounding box":
        var tree = newQuadtree[Box]()
        expect(AssertionError):
            tree.insert( (left: 1, top: 1, width: -3, height: 3) )
        expect(AssertionError):
            tree.insert( (left: 1, top: 1, width: 3, height: -3) )
        expect(AssertionError):
            tree.insert( (left: 1, top: 1, width: -3, height: -3) )

    test "Delete elements from a tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (left: 1, top: 1, width: 3, height: 3) )
        tree.insert( (left: 1, top: 1, width: 3, height: 3) )
        tree.insert( (left: 9, top: 9, width: 3, height: 3) )

        tree.delete( (left: 1, top: 1, width: 3, height: 3) )
        require(tree.fetch(2, 2) == empty)
        require(tree.fetch(9, 9) == @[ (left: 9, top: 9, width: 3, height: 3) ])

        tree.delete( (left: 9, top: 9, width: 3, height: 3) )
        require(tree.fetch(9, 9) == empty)

