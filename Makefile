#!/usr/bin/env make -f

VERSION := $(shell cat package.json | grep version | head -n1 | cut -d \" -f 4)

tempdir        := $(shell mktemp -d)
controldir     := $(tempdir)/DEBIAN
installpath    := $(tempdir)/opt/ninja/drivers/ninja-hue2

define DEB_CONTROL
Package: ninja-hue2
Version: $(VERSION)
Architecture: amd64
Maintainer: "Mark Wolfe" <mark.wolfe@ninjablocks.com>
Section: ninjablocks
Priority: optional
Description: Driver for the hue light globes.
endef
export DEB_CONTROL

deb: driver/ninja-hue2
	mkdir -p -m 0755 $(controldir)
	echo "$$DEB_CONTROL" > $(controldir)/control
	mkdir -p $(installpath)
	cp -R  node_modules $(installpath)
	install README.md $(installpath)/README.md
	install index.js $(installpath)/index.js
	install lampstealer.js $(installpath)/lampstealer.js
	install package.json $(installpath)/package.json
	install test.js $(installpath)/test.js
	fakeroot dpkg-deb --build $(tempdir) .
	rm -rf $(tempdir)

driver/ninja-hue2:
	git clone git://github.com/heroku/heroku-buildpack-nodejs.git .build
	.build/bin/compile . .build/cache/

clean:
	rm -rf ./node_modules
	rm -rf .build/
	rm -rf ./.profile.d/
	rm -f ninja-hue2*.deb

build: driver/ninja-hue2