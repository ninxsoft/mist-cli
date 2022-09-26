identifier = com.ninxsoft.pkg.mist-cli
identity_app = Developer ID Application: Nindi Gill (7K3HVCLV7Z)
identity_pkg = Developer ID Installer: Nindi Gill (7K3HVCLV7Z)
binary = mist
source = .build/apple/Products/release/$(binary)
destination = /usr/local/bin/$(binary)
temp = /private/tmp/$(identifier)
version = $(shell mist --version | awk '{ print $$1 }')
min_os_version = 10.15
package_dir = build
package = $(package_dir)/mist-cli $(version).pkg

build:
	swift build --configuration release --arch arm64 --arch x86_64
	codesign --sign "$(identity_app)" --options runtime "$(source)"

install: build
	install "$(source)" "$(destination)"

package: install
	mkdir -p "$(temp)/usr/local/bin"
	mkdir -p "$(package_dir)"
	cp "$(destination)" "$(temp)$(destination)"
	pkgbuild --root "$(temp)" \
			 --identifier "$(identifier)" \
			 --version "$(version)" \
			 --min-os-version "$(min_os_version)" \
			 --sign "$(identity_pkg)" \
			 "$(package)"
	rm -r "$(temp)"

uninstall:
	rm -rf "$(destination)"

clean:
	rm -rf .build

.PHONY: build install package uninstall clean
