#!/usr/bin/env bash
# Prints GOPROXY and GONOSUMDB settings that serve the native modules the
# pinned haybarn-go-bindings version requires. If the bindings' origin already
# publishes them, the settings select the origin; otherwise the modules are
# packaged from the pinned Haybarn release archives into LIB_WORK (the same
# bytes and go.sum hashes the published modules will have) and served from
# there. Usage: eval "$(scripts/native-proxy.sh)" or append to $GITHUB_ENV.
set -euo pipefail

bindings=github.com/Query-farm-haybarn/haybarn-go-bindings
# Read the pin from go.mod: resolving the build list would need the modules
# this script provides.
pin=$(go mod edit -json | jq -r --arg p "$bindings" '.Require[] | select(.Path == $p) | .Version')
dir=$(go mod download -json "$bindings@$pin" | jq -r .Dir)
manifest="$dir/duckdb-release.json"
origin=$(jq -r .origin "$manifest")
version=$(jq -r .version "$manifest")
prefix="${origin#https://}/libhaybarn"
platform=$(jq -r '.platforms | keys[0]' "$manifest")

if curl -fsS -o /dev/null 2>/dev/null "$origin/modules/$prefix/$platform/@v/$version.info"; then
	echo "GOPROXY=$origin/modules,https://proxy.golang.org"
else
	export LIB_WORK=${LIB_WORK:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}/haybarn-go-libraries}
	(cd "$dir" && GOWORK=off GOFLAGS=-mod=mod go run ./internal/cmd/brood package) >&2
	echo "GOPROXY=file://$LIB_WORK/modules,https://proxy.golang.org"
fi
echo "GONOSUMDB=$prefix"
