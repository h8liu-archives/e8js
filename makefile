.PHONY: comp test

e8.js: src/*.coffee
	coffee -j e8.js -c src/*.coffee
	cp e8.js www/.

test: e8.js
	coffee test/align.coffee
	coffee test/vm.coffee
