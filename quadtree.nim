##
## A Quadtree implementation
##

import math

type
    GridUnit = float
        ## The units for measurement in the grid

    BoundingBox* = tuple[top, left, width, height: GridUnit]
        ## The position and dimensions of a bounding box

    Quadable* = concept q
        ## An element that can be stored in a quadtree
        boundingBox(q) is BoundingBox
        contains(BoundingBox, q) is bool

    NodeKind = enum ## \
        ## The polymorphic type of a node
        ## * Leaf nodes contain elements
        ## * parent nodes contain quadrants
        leaf, parent

    Node[E] = ref object
        ## A node within the quadtree
        ## * `x` and `y` are the coordinates for the center of the box
        ## * `halfSize` is half the length of any side of this Node

        x, y: GridUnit
        halfSize: GridUnit

        case kind: NodeKind
        of leaf:
            elems: seq[E]
        of parent:
            nw, ne, se, sw: Node[E]

    Quadtree[E] = object
        ## A Quadtree instance
        ## * `E` is the type of element being stored
        ## * `maxInQuadrant` is the maximum number of elements to store in a
        ##   quadrant before dividing it
        ## * `divideAttempts` is the maximum number of times to subdivide a
        ##   quadrant before giving up. For example, let's say you add the same
        ##   object to this quadtree fifty times; It doesn't matter how many
        ##   times we try to divide.
        ## * `root` is the root node
        maxInQuadrant: int
        divideAttempts: int
        root: Node[E]



proc newQuadtree*[E: Quadable](
    maxInQuadrant: int = 2,
    divideAttempts: int = 4
): Quadtree[E] =
    ## Creates a new quadtree
    Quadtree[E](
        maxInQuadrant: maxInQuadrant,
        divideAttempts: divideAttempts,
        root: nil
    )


proc createRoot[E]( tree: var Quadtree[E], elem: E ) =
    ## Creates a root node when adding to an empty tree
    let box = elem.boundingBox

    # Find the largest dimension, then double it so this object
    # will fill entirely into a single quadrant
    let dimension = max(box.width, box.height) * 2

    # Round up to the closest power of two to make the numbers easier to
    # work with
    let roundedUp = pow(2, ceil(log10(dimension) / log10(2)))

    tree.root = Node[E](
        x: box.top, y: box.left,
        halfSize: roundedUp,
        kind: leaf,
        elems: @[ elem ]
    )

proc insert*[E: Quadable]( tree: var Quadtree[E], elem: E ) =
    ## Adds a new element to a quadtree

    if tree.root == nil:
        createRoot(tree, elem)
    else:
        discard

proc fetch[E]( node: Node[E], x, y: GridUnit ): seq[E] =
    ## Descends into a tree to find the values stored for a given point
    if node == nil:
        return @[]

    elif node.kind == leaf:
        return node.elems

    else:
        raise newException(AssertionError, "Unimplemented")

proc fetch*[E: Quadable]( tree: Quadtree[E], x, y: GridUnit ): seq[E] =
    ## Returns the elements at the given coordinate
    return fetch(tree.root, x, y)



