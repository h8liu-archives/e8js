.PHONY: comp test

comp:
	coffee -j e8.js -c \
		src/align.coffee \
		src/mem.coffee \
		src/inst.coffee \
		src/vm.coffee \
		#

test:
	coffee test/align.coffee
