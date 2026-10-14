# Haybarn engine release the optional dynamic/static-lib test targets pull from.
HAYBARN_REPO=Query-farm-haybarn/haybarn
HAYBARN_VERSION=haybarn-v1.5.6-rc1

test.examples:
	go run examples/appender/main.go
	go run examples/json/main.go
	go run examples/scalar_udf/main.go
	go run examples/simple/main.go
	go run examples/table_udf/main.go
	go run examples/table_udf_parallel/main.go

test.dynamic.lib:
	mkdir dynamic-dir && \
	cd dynamic-dir && \
	curl -OL https://github.com/${HAYBARN_REPO}/releases/download/${HAYBARN_VERSION}/${FILENAME}.zip && \
	unzip ${FILENAME}.zip

test.static.lib.darwin.arm64:
	mkdir static-dir && \
	cd static-dir && \
	curl -OL https://github.com/${HAYBARN_REPO}/releases/download/${HAYBARN_VERSION}/static-libs-osx-arm64.zip && \
	unzip static-libs-osx-arm64.zip

GOBIN ?= $$(go env GOPATH)/bin

install-go-test-coverage:
	go install github.com/vladopajic/go-test-coverage/v2@latest

check-coverage: install-go-test-coverage
	go test ./... -coverprofile=./cover.out -covermode=atomic -coverpkg=./...
	${GOBIN}/go-test-coverage --config=./.github/testcoverage.yml
	go tool cover -html=cover.out -o=cover.html
