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

type Box = tuple[x, y, width, height: int]
    ## This represents whatever type you want to store in the tree

var tree = newQuadtree[Box]()

tree.insert( (x: 1, y: 1, width: 5, height: 4) )
tree.insert( (x: 2, y: 3, width: 5, height: 5) )
tree.insert( (x: 19, y: 4, width: 3, height: 1) )

# Grab all the elements that are near (2, 2)
echo tree.fetch(2, 2)
```

License
-------

This library is released under the MIT License, which is pretty spiffy. You
should have received a copy of the MIT License along with this program. If
not, see http://www.opensource.org/licenses/mit-license.php





[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Nycto/quadtreenim/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

