.PHONY: comp test all

all: e8.js www/js/w.js

e8.js: src/*.coffee
	coffee -j e8.js -c src/*.coffee
	cp e8.js www/js/e8.js

www/js/w.js: src/www/*.coffee
	coffee -j www/js/w.js -c src/www/*.coffee

test: e8.js
	coffee test/align.coffee
	coffee test/vm.coffee
