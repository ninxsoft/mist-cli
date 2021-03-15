binary = mist
destination = /usr/local/bin/$(binary)

build:
	swift build --configuration release

install: build
	install ".build/release/$(binary)" "/usr/local/bin/$(binary)"

uninstall:
	rm -rf "$(destination)"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
