import unittest, quadtree, options


type
    Box = tuple[x, y, width, height: int]

    InvalidContains = object
        x, y, width, height: int

proc contains*( bound: Square, elem: Box ): bool =
    if bound.x + bound.size < elem.x: return false
    if bound.x > elem.x + elem.width: return false
    if bound.y + bound.size < elem.y: return false
    if bound.y > elem.y + elem.height: return false
    return true

proc contains*( bound: Square, elem: InvalidContains ): bool = false


suite "Quadtrees should":

    let empty: seq[Box] = @[]

    test "Return an empty seq when fetching from an empty quadtree":
        let tree = newQuadtree[Box]()
        require( tree.fetch(0, 0) == empty )

    test "Add and fetch a single bounding box":
        var tree = newQuadtree[Box]()
        let box: Box = (x: 0, y: 0, width: 5, height: 5)
        tree.insert( box )
        require(tree.bounds.get == (y: -1, x: -1, size: 32))
        require( tree.fetch(0, 0) == @[ box ] )

    test "Adding to a tree without subdividing":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        let box1: Box = (x: 1, y: 1, width: 5, height: 5)
        let box2: Box = (x: 4, y: 4, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: 0, x: 0, size: 32))
        require( tree.fetch(3, 3) == @[ box1, box2 ] )

    test "Convert to a string":
        var tree = newQuadtree[Box](maxInQuadrant = 5)
        discard $tree

    test "Subdividing a leaf node after it gets full":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        let box1: Box = (x: 0, y: 0, width: 4, height: 4)
        let box2: Box = (x: 10, y: 1, width: 2, height: 2)
        tree.insert( box1 )
        tree.insert( box2 )
        require(tree.bounds.get == (y: -1, x: -1, size: 16))
        require( tree.fetch(1, 1) == @[ box1 ] )
        require( tree.fetch(11, 1) == @[ box2 ] )

    test "Return the bouding box of a tree":
        var tree = newQuadtree[Box]()
        require( tree.bounds == none(Square) )
        tree.insert( (x: 10, y: 2, width: 2, height: 2) )
        require(tree.bounds.get == (y: 1, x: 9, size: 8))

    test "Expand the boundaries when adding an outside right element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        require(tree.bounds.get == (y: 4, x: 2, size: 8))

        tree.insert( (x: 10, y: 5, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside bottom element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: 5, y: 12, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside x element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: -3, y: 6, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding an outside y element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: 4, y: -2, width: 2, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding a tall element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: 4, y: 6, width: 2, height: 20) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the boundaries when adding a wide element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: 4, y: 6, width: 20, height: 2) )
        require(tree.bounds.get == (y: -4, x: -6, size: 32))

    test "Expand the until it fits the new element":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 3, y: 5, width: 2, height: 2) )
        tree.insert( (x: 90000, y: 6, width: 20, height: 2) )
        require(tree.bounds.get == (y: -174756, x: -174758, size: 524288))

    test "Allow the same element to be added many times":
        var tree = newQuadtree[Box]()
        tree.insert( (x: 0, y: 0, width: 1, height: 1) )
        tree.insert( (x: 0, y: 0, width: 1, height: 1) )
        tree.insert( (x: 0, y: 0, width: 1, height: 1) )
        tree.insert( (x: 0, y: 0, width: 1, height: 1) )
        tree.insert( (x: 0, y: 0, width: 1, height: 1) )

        require(tree.fetch(0, 0) == @[
            (x: 0, y: 0, width: 1, height: 1),
            (x: 0, y: 0, width: 1, height: 1),
            (x: 0, y: 0, width: 1, height: 1),
            (x: 0, y: 0, width: 1, height: 1),
            (x: 0, y: 0, width: 1, height: 1)
        ])

    test "Fetching from an empty quadrant":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (x: 1, y: 1, width: 3, height: 3) )
        tree.insert( (x: 2, y: 2, width: 2, height: 2) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(9, 0) == empty)
        require(tree.fetch(10, 10) == empty)
        require(tree.fetch(0, 11) == empty)

    test "Fetching from outside a tree with a single node tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (x: 1, y: 1, width: 3, height: 3) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(-5, 5) == empty)
        require(tree.fetch(5, -5) == empty)
        require(tree.fetch(5, 20) == empty)
        require(tree.fetch(20, 5) == empty)

    test "Fetching from outside a tree with a multi-node tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (x: 1, y: 1, width: 3, height: 3) )
        tree.insert( (x: 9, y: 9, width: 3, height: 3) )
        require(tree.bounds.get == (y: 0, x: 0, size: 16))
        require(tree.fetch(-5, 5) == empty)
        require(tree.fetch(5, -5) == empty)
        require(tree.fetch(5, 20) == empty)
        require(tree.fetch(20, 5) == empty)

    test "Throw an error when an element isnt added to any quadrant":
        var tree = newQuadtree[InvalidContains](maxInQuadrant = 1)
        tree.insert( InvalidContains(x: 1, y: 1, width: 3, height: 3) )
        expect(AssertionError):
            tree.insert( InvalidContains(x: 9, y: 9, width: 3, height: 3) )

    test "Disallow negative widths and heights on a bounding box":
        var tree = newQuadtree[Box]()
        expect(AssertionError):
            tree.insert( (x: 1, y: 1, width: -3, height: 3) )
        expect(AssertionError):
            tree.insert( (x: 1, y: 1, width: 3, height: -3) )
        expect(AssertionError):
            tree.insert( (x: 1, y: 1, width: -3, height: -3) )

    test "Delete elements from a tree":
        var tree = newQuadtree[Box](maxInQuadrant = 1)
        tree.insert( (x: 1, y: 1, width: 3, height: 3) )
        tree.insert( (x: 1, y: 1, width: 3, height: 3) )
        tree.insert( (x: 9, y: 9, width: 3, height: 3) )

        tree.delete( (x: 1, y: 1, width: 3, height: 3) )
        require(tree.fetch(2, 2) == empty)
        require(tree.fetch(9, 9) == @[ (x: 9, y: 9, width: 3, height: 3) ])

        tree.delete( (x: 9, y: 9, width: 3, height: 3) )
        require(tree.fetch(9, 9) == empty)

