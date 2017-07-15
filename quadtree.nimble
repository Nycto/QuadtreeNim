# Package
version       = "0.3.1"
author        = "Nycto"
description   = "A Quadtree Implementation"
license       = "MIT"
skipDirs      = @["test", ".build"]

# Deps
requires "nim >= 0.13.0"

exec "test -d .build/ExtraNimble || git clone https://github.com/Nycto/ExtraNimble.git .build/ExtraNimble"
include ".build/ExtraNimble/extranimble.nim"
