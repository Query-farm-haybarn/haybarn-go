BINDINGS=github.com/Query-farm-haybarn/haybarn-go-bindings
NATIVE_DARWIN_ARM64=haybarn-extensions.query.farm/go/libhaybarn/darwin-arm64
PLATFORM ?= $(shell go env GOOS)-$(shell go env GOARCH)
SHA256SUM := $(shell command -v sha256sum >/dev/null && echo sha256sum || echo shasum -a 256)

test.examples:
	go run examples/appender/main.go
	go run examples/json/main.go
	go run examples/scalar_udf/main.go
	go run examples/simple/main.go
	go run examples/table_udf/main.go
	go run examples/table_udf_parallel/main.go

# Download the shared library that the bindings pin for PLATFORM, and verify its checksum.
test.dynamic.lib:
	manifest="$$(go list -f '{{.Dir}}' ${BINDINGS})/duckdb-release.json" && \
	base_url=$$(jq -r .base_url "$$manifest") && \
	artifact=$$(jq -er '.platforms["${PLATFORM}"].shared' "$$manifest") && \
	sha256=$$(jq -er '.platforms["${PLATFORM}"].shared_sha256' "$$manifest") && \
	mkdir dynamic-dir && \
	curl -fsSL -o dynamic-dir/libs.zip "$$base_url/libhaybarn-$$artifact.zip" && \
	echo "$$sha256  dynamic-dir/libs.zip" | ${SHA256SUM} -c - && \
	unzip -q dynamic-dir/libs.zip -d dynamic-dir && \
	rm dynamic-dir/libs.zip

# Copy the static archives of the bindings' darwin-arm64 module and build their extension loader.
test.static.lib.darwin.arm64:
	native=$$(go list -f '{{.Dir}}' ${NATIVE_DARWIN_ARM64}) && \
	mkdir static-dir && \
	cp "$$native"/*.a static-dir && \
	cc -c "$$native/static_extension_loader.c" -o static-dir/static_extension_loader.o && \
	ar rcs static-dir/libduckdb_static_extension_loader.a static-dir/static_extension_loader.o

GOBIN ?= $$(go env GOPATH)/bin

install-go-test-coverage:
	go install github.com/vladopajic/go-test-coverage/v2@latest

check-coverage: install-go-test-coverage
	go test ./... -coverprofile=./cover.out -covermode=atomic -coverpkg=./...
	${GOBIN}/go-test-coverage --config=./.github/testcoverage.yml
	go tool cover -html=cover.out -o=cover.html
