CICI_PACKAGES = $$(go list ./... | grep -v '/vendor/')
CICI_FILES = $$(find . -type f -name "*.go" | grep -v '/vendor/')
CICI_BIN = bin/cici

.PHONY: default all build configure vendor fmt test lint install clean

# Must be first to actually be default
default: fmt test lint install

.fmt: $(shell find . -name "*.go")
	go fmt 
fmt: .fmt

all: configure fmt lint test build

build: $(CICI_BIN)
$(CICI_BIN): $(shell find . -name '*.go' -type f)
	go get
	go build -i -v \
		-ldflags="-X main.version=$$(cat VERSION | xargs echo -n)" \
		-o $(CICI_BIN) \
		cici.go

clean:
	rm -rfv bin
	rm -fv $(CICI_TEMPLATE_GENS)

configure:
	go get -u github.com/axw/gocov/...
	go get -u github.com/AlekSi/gocov-xml
	go get -u github.com/golang/lint/golint
	go get -u gopkg.in/check.v1
	go get -u gopkg.in/jarcoal/httpmock.v1

fmt:
	gofmt -l -s -w $(CICI_FILES)

install: $(CICI_BIN)
	cp $(CICI_BIN) $${GOPATH}/$(CICI_BIN)

install-global: $(CICI_BIN)
	cp $(CICI_BIN) /usr/local/$(CICI_BIN)

lint:
	go tool vet ./*/*.go \
		&& find . -maxdepth 2 -name "*.go" | xargs -n1 golint

test:
	TEST=1 go test -v $(CICI_PACKAGES)

vendor:
	godep get ./...
	godep save
