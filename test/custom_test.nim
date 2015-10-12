import unittest, quadtree, options, math


type Box = tuple[left, top, size: int]

proc boundingBox*( b: Box ): tuple[y, x, width, height: int] =
    return ( y: b.top, x: b.left, width: b.size, height: b.size )


type InvalidContains = object
    x, y, width, height: int

proc contains*( bound: Square, elem: InvalidContains ): bool = false


type Circle = tuple[x, y, radius: int]

proc boundingBox*( c: Circle ): tuple[x, y, width, height: int] =
    return (
        x: c.x - c.radius, y: c.y - c.radius,
        width: c.radius * 2, height: c.radius * 2
    )

proc clamp(n, smallest, largest: auto): auto = max(smallest, min(n, largest))
    ## Limits the given number to a set of boundaries

proc contains*( rect: Square, circle: Circle ): bool =
    # Find the closest point to the circle within the rectangle
    let closestX = clamp(circle.x, rect.x, rect.x + rect.size)
    let closestY = clamp(circle.y, rect.y, rect.y + rect.size)

    # Calculate the distance between the circle's center and this closest point
    let distanceX = circle.x - closestX
    let distanceY = circle.y - closestY

    # If the distance is less than the circle's radius, an intersection occurs
    let distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)

    return distanceSquared < (circle.radius * circle.radius)


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

    test "Throw an error when an element isnt added to any quadrant":
        var tree = newQuadtree[InvalidContains](maxInQuadrant = 1)
        tree.insert( InvalidContains(x: 1, y: 1, width: 3, height: 3) )
        expect(AssertionError):
            tree.insert( InvalidContains(x: 9, y: 9, width: 3, height: 3) )

    test "Use a custom 'contains' function when available":
        var tree = newQuadtree[Circle](maxInQuadrant = 1)

        let circle1 = (x: 0, y: 0, radius: 4)
        tree.insert( circle1 )
        require(tree.bounds.get == (y: -5, x: -5, size: 32))
        require( tree.fetch(4, 4) == @[ circle1 ] )

        let circle2 = (x: 5, y: 5, radius: 1)
        tree.insert( circle2 )
        require(tree.bounds.get == (y: -5, x: -5, size: 32))
        require( tree.fetch(4, 4) == @[ circle2 ] )


