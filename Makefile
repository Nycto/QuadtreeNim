
# Generates documentation for mainline
.PHONY: doc
doc:
	$(eval HASH := $(shell git rev-parse master))
	git show $(HASH):quadtree.nim > quadtree.nim
	nim doc quadtree.nim
	git add quadtree.html
	git commit -m "Generate docs from $(HASH)"

