##
## A Quadtree implementation
##

import math, ropes, strutils, options, sequtils

type
    Bounds* = concept b
        ## The position and dimensions of a bounding box
        b.top is int
        b.left is int
        b.width is int
        b.height is int

    BoundingBox* = tuple[top, left, width, height: int]
        ## A concrete `Bounds` implementation

    Square* = tuple[top, left, size: int]
        ## A square on a grid

    Quadable* = concept q
        ## An element that can be stored in a quadtree
        boundingBox(q) is Bounds
        contains(Square, q) is bool
        `==`(q, q) is bool

    Half {.pure.} = enum ## \
        ## Represents half of a node; north vs south, east vs west
        low, high, neither

    Quadrant = enum ## \
        ## The four subquadrants of a node
        northwest, northeast, southeast, southwest

    Node[E] = ref object
        ## A node within the quadtree
        ## * `top` and `left` are the coordinates for the box
        ## * `halfSize` is half the length of any side of this Node
        ## * `elems` is a list of elements in this node. When this is `nil`, the
        ##   node is flagged as a parent. Yes, this is probably an abuse of
        ##   `nil`, but it isn't exposed outside of this library.
        ## * `quad` is a list of sub-quadrants when this node is a parent
        top, left: int
        halfSize: int
        elems: seq[E]
        quad: array[northwest..southwest, Node[E]]

    Quadtree[E] = object
        ## A Quadtree instance
        ## * `E` is the type of element being stored
        ## * `maxInQuadrant` is the maximum number of elements to store in a
        ##   quadrant before dividing it
        ## * `root` is the root node
        maxInQuadrant: int
        root: Node[E]



proc ceilPow2( value: int ): int =
    ## Rounds up to the closest power of 2
    result = 1
    while result < value:
        result = result shl 1


iterator quadrants(): Quadrant =
    ## Yields each of the 4 quadrants
    yield northwest
    yield northeast
    yield southeast
    yield southwest


proc isLeaf[E]( node: Node[E] ): bool {.inline.} =
    ## Whether a node is a leaf in the tree
    node.elems != nil

proc fullSize[E]( node: Node[E] ): int {.inline.} =
    ## The full width of a node
    2 * node.halfSize

proc canSubdivide[E]( node: Node[E] ): bool {.inline.} =
    ## Returns whether a node can be subdivided further
    node.halfSize > 1

proc quadrantBox[E]( node: Node[E], quad: Quadrant ): Square {.inline.} =
    ## Returns the bounding box for a quadrant
    let size = node.halfSize
    case quad
    of northwest: (node.top, node.left, size)
    of northeast: (node.top, node.left + size, size)
    of southeast: (node.top + size, node.left + size, size)
    of southwest: (node.top + size, node.left, size)

template fullyContains[E]( node: Node[E], quad: Bounds ): bool =
    ## Returns whether the given node fully contains the given bounding box
    if quad.left < node.left:
        false
    elif quad.left + quad.width > node.left + fullSize(node):
        false
    elif quad.top < node.top:
        false
    elif quad.top + quad.height > node.top + fullSize(node):
        false
    else:
        true


proc newQuadtree*[E: Quadable](
    maxInQuadrant: int = 2,
): Quadtree[E] =
    ## Creates a new quadtree
    Quadtree[E]( maxInQuadrant: maxInQuadrant, root: nil )

proc `$`[E]( node: Node[E], accum: var Rope ) =
    ## Convert a node to a string and add it to a Rope
    if node == nil:
        accum.add("empty")
    elif node.isLeaf:
        accum.add($(node.elems))
    else:
        var first = true
        for quad in quadrants():
            if not first:
                accum.add(", ")
            first = false
            accum.add($quad)
            accum.add("(")
            `$`[E](node.quad[quad], accum)
            accum.add(")")

proc `$`*[E: Quadable]( tree: Quadtree[E] ): string =
    ## Convert a Quadtree to a string
    var accum = rope("Quadtree(")
    `$`[E](tree.root, accum)
    accum.add(")")
    return $accum

proc bounds*[E: Quadable]( tree: Quadtree[E] ): Option[Square] =
    ## Returns the overall bounding box for a tree. This will be 'none' if
    ## this tree doesn't have any content
    if tree.root == nil:
        return none(Square)
    else:
        return some[Square]((
            top: tree.root.top,
            left: tree.root.left,
            size: tree.root.fullSize
        ))



# Forward declaration so this can be referenced by 'insertIntoQuadrant'
proc insert[E](tree: var Quadtree[E], node: var Node[E], elem: E)

proc insertIntoQuadrant[E](tree: var Quadtree[E], node: var Node[E], elem: E) =
    ## Inserts a node into the quadrants of the given node

    var added = false
    for quad in quadrants():
        let box = node.quadrantBox(quad)
        if contains(box, elem):
            if node.quad[quad] == nil:
                node.quad[quad] = Node[E](
                    top: box.top, left: box.left,
                    halfSize: int(box.size / 2),
                    elems: @[ elem ])
            else:
                tree.insert(node.quad[quad], elem)
            added = true

    if not added:
        raise newException( AssertionError,
            ("Element ($#) was not added to any quadrant. " &
            "Tried adding to $#, $#, $# and $#") % [
                $elem,
                $(node.quadrantBox(northwest)), $(node.quadrantBox(northeast)),
                $(node.quadrantBox(southeast)), $(node.quadrantBox(southwest))
            ]
        )

proc subdivide[E]( tree: var Quadtree[E], node: var Node[E] ) =
    ## Builds a parent node from a leaf node
    assert( node.halfSize > 1 )
    assert( node.isLeaf )

    # Distribute the elements in this node into the subquadrants
    for elem in node.elems:
        tree.insertIntoQuadrant(node, elem)

    # Clearing out the 'elems' property makes a node a parent
    node.elems = nil
    assert( not node.isLeaf )

proc insert[E](tree: var Quadtree[E], node: var Node[E], elem: E) =
    ## Adds the given value to this node. Returns the node that was created
    ## or used to house this addition

    # If we have reached a terminal node, figure out if it has capacity to
    # store another element, or if it needs to be subdivided
    if node.isLeaf:
        if node.elems.len >= tree.maxInQuadrant and node.canSubdivide:
            tree.subdivide(node)
            tree.insert( node, elem )
        else:
            node.elems.add( elem )

    # Recurse deeper into the tree to insert this node
    else:
        tree.insertIntoQuadrant(node, elem)

proc expand[E]( tree: var Quadtree[E] ) {.inline.} =
    ## Expands the bounding box of the tree in all directions

    # Expand towards the upper left
    let inner = Node[E](
        top: tree.root.top - tree.root.fullSize,
        left: tree.root.left - tree.root.fullSize,
        halfSize: tree.root.fullSize,
        elems: nil)
    inner.quad[southeast] = tree.root

    # Expand towards the lower right
    tree.root = Node[E](
        top: inner.top,
        left: inner.left,
        halfSize: inner.fullSize,
        elems: nil)
    inner.quad[northwest] = inner

proc insert*[E: Quadable]( tree: var Quadtree[E], elem: E ) =
    ## Adds a new element to a quadtree
    let box = elem.boundingBox

    assert(box.width >= 0 and box.height >= 0)

    # Creates a root node when adding to an empty tree
    if tree.root == nil:
        tree.root = Node[E](
            top: box.top - 1, left: box.left - 1,
            halfSize: ceilPow2( max(box.width, box.height, 2) * 2 ),
            elems: @[ elem ])

    else:
        # Expand the root until it fits this element
        while not fullyContains(tree.root, box):
            expand(tree)

        tree.insert(tree.root, elem)



proc getHalf( baseOffset: int, halfSize: int, point: int): Half {.inline.} =
    ## Returns the half of a node in which a coordinate falls
    if point < baseOffset + halfSize:
        if point < baseOffset:
            return Half.neither
        else:
            return Half.low
    else:
        if point > baseOffset + 2 * halfSize:
            return Half.neither
        else:
            return Half.high

proc getQuadrant( vertical: Half, horizontal: Half ): Quadrant {.inline.} =
    ## Maps two halves to the quadrant
    case vertical
    of Half.low:
        case horizontal
        of Half.low: return northwest
        of Half.high: return northeast
        of Half.neither: assert( horizontal != Half.neither )
    of Half.high:
        case horizontal
        of Half.low: return southwest
        of Half.high: return southeast
        of Half.neither: assert( horizontal != Half.neither )
    of Half.neither: assert( vertical != Half.neither )

proc fetch[E]( node: Node[E], x, y: int ): seq[E] =
    ## Descends into a tree to find the values stored for a given point
    if node == nil:
        return @[]

    let horiz = getHalf(node.left, node.halfSize, x)
    let vert = getHalf(node.top, node.halfSize, y)

    if horiz == Half.neither or vert == Half.neither:
        return @[]
    elif node.isLeaf:
        return node.elems
    else:
        return fetch(node.quad[getQuadrant(vert, horiz)], x, y)

proc fetch*[E: Quadable]( tree: Quadtree[E], x, y: int ): seq[E] =
    ## Returns the elements at the given coordinate
    return fetch(tree.root, x, y)


proc delete[E]( node: var Node[E], elem: E ): bool =
    ## Deletes an element from this node. Returns true if this node is left
    ## empty because of the delete
    if node.isLeaf:
        keepIf(node.elems, proc(vs: E): bool = not(elem == vs))
        return node.elems.len == 0
    else:
        var emptyQuadrants = 0
        for quad in quadrants():
            if node.quad[quad] == nil:
                inc(emptyQuadrants)
            elif node.quadrantBox(quad).contains(elem):
                if node.quad[quad].delete(elem):
                    node.quad[quad] = nil
                    inc(emptyQuadrants)
        return emptyQuadrants == 4

proc delete*[E: Quadable]( tree: var Quadtree[E], elem: E ) =
    ## Removes the given element from this quadtree
    if tree.root != nil:
        if tree.root.delete(elem):
            tree.root = nil

