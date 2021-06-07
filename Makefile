.PHONY: utilities lint dependency clean build release all

VERSION_MAJOR  := 1
VERSION_MINOR  := 0
VERSION_PATCH  := 0
VERSION_SUFFIX := ""

COMMIT  := $(shell git describe --always)
PKGS    := $(shell go list ./...)
REPO    := github.com/rewanthtammana/kubectl-whisper-secret
VERSION := v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)$(VERSION_SUFFIX)
LDFLAGS := -s -w -X $(REPO)/cmd.version=$(VERSION)

export GO111MODULE=on

default: build

utilities:
	@echo "Download Utilities..."
	go get -u golang.org/x/lint/golint
	go get -u github.com/tcnksm/ghr

lint:
	@echo "Source Code Lint..."
	@for i in $(PKGS); do echo $${i}; golint $${i}; done

dependency:
	go mod download

build-linux:
	@echo "Creating Build for Linux..."
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o ./releases/$(VERSION)/Linux-x86_64/kubectl-whisper-secret
	@cp LICENSE ./releases/$(VERSION)/Linux-x86_64
	@tar zcf ./releases/$(VERSION)/kubectl-whisper-secret-Linux-x86_64.tar.gz -C releases/$(VERSION)/Linux-x86_64 kubectl-whisper-secret LICENSE

build-darwin:
	@echo "Creating Build for macOS..."
	@CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o ./releases/$(VERSION)/Darwin-x86_64/kubectl-whisper-secret
	@cp LICENSE ./releases/$(VERSION)/Darwin-x86_64
	@tar zcf ./releases/$(VERSION)/kubectl-whisper-secret-Darwin-x86_64.tar.gz -C releases/$(VERSION)/Darwin-x86_64 kubectl-whisper-secret LICENSE

build-windows:
	@echo "Creating Build for Windows..."
	@CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o ./releases/$(VERSION)/Windows-x86_64/kubectl-whisper-secret.exe
	@cp LICENSE ./releases/$(VERSION)/Windows-x86_64
	@zip -j ./releases/$(VERSION)/kubectl-whisper-secret-Windows-x86_64.zip releases/$(VERSION)/Windows-x86_64/kubectl-whisper-secret.exe LICENSE

build: build-linux build-darwin build-windows

clean:
	@echo "Cleanup Releases..."
	rm -rf ./releases/*

release:
	@echo "Creating Releases..."
	go get -u github.com/tcnksm/ghr
	ghr -t ${GITHUB_TOKEN} $(VERSION) releases/$(VERSION)/
	sha256sum releases/$(VERSION)/*.{zip,tar.gz} > releases/$(VERSION)/SHA256SUM

all: utilities lint dependency clean build
