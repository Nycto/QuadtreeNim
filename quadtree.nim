##
## A Quadtree implementation
##

type
    GridUnit = float

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
        ## A node within
        case kind: NodeKind
        of leaf:
            element: seq[E]
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

proc insert*[E]( tree: var Quadtree[E], elem: E ) =
    ## Adds a new element to a quadtree
    discard

proc fetch*[E]( tree: Quadtree[E], x, y: GridUnit ): seq[E] =
    ## Returns the elements at the given coordinate
    return @[]



