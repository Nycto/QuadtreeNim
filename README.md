QuadtreeNim [![Build Status](https://travis-ci.org/Nycto/QuadtreeNim.svg?branch=master)](https://travis-ci.org/Nycto/QuadtreeNim)
===========

A Quadtree library in Nim. Quadtrees are a way of indexing objects on a grid.
You can find a reasonable introduction here:

http://gamedevelopment.tutsplus.com/tutorials/make-your-game-pop-with-particle-effects-and-quadtrees--gamedev-2138

API Docs
--------

http://nycto.github.io/QuadtreeNim/quadtree.html

A Small Example
---------------

```nimrod
import quadtree

type Box = tuple[x, y, size: int]
    ## This represents whatever type you want to store in the tree

proc boundingBox*( b: Box ): BoundingBox =
    ## Required by the Quadtree library; Returns a box that contains the
    ## entirety of an element
    return ( y: b.y, x: b.x, width: b.size, height: b.size )

proc contains*( bound: Square, elem: Box ): bool =
    ## Required by the Quadtree library; Returns whether the given bounding
    ## box contains part of the given element
    if bound.x + bound.size < elem.x: return false
    if bound.x > elem.x + elem.size: return false
    if bound.y + bound.size < elem.y: return false
    if bound.y > elem.y + elem.size: return false
    return true

var tree = newQuadtree[Box]()

tree.insert( (x: 1, y: 1, size: 5) )
tree.insert( (x: 2, y: 3, size: 5) )
tree.insert( (x: 19, y: 4, size: 3) )

# Grab all the elements that are near (2, 2)
echo tree.fetch(2, 2)
```

License
-------

This library is released under the MIT License, which is pretty spiffy. You
should have received a copy of the MIT License along with this program. If
not, see http://www.opensource.org/licenses/mit-license.php



