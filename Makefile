.PHONY: build run test app clean bump-version

build:
	swift build

run: build
	swift run MacDaily

test:
	swift test

app:
	./packaging/build-app.sh

clean:
	rm -rf .build dist

bump-version:
	chmod +x packaging/bump-version.sh
	./packaging/bump-version.sh $(or $(BUMP),patch)
