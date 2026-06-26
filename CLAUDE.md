# CLAUDE.md — haybarn-go

Guidance for Claude Code (and humans) working in this repository.

## What this repo is

The `database/sql` driver for **Haybarn** (Query Farm LLC's independent derived
distribution of DuckDB). Hard fork of `duckdb/duckdb-go`, sitting on top of
[`haybarn-go-bindings`](https://github.com/Query-farm-haybarn/haybarn-go-bindings).
A thin layer over the bindings — most of the engine and all "Haybarn-ness" live
below, in `libhaybarn_static.a` linked by the bindings.

Kept a **thin diff** over upstream for rebaseability:

- **Renamed:** module path (`.../haybarn-go/v2`) and all imports incl. the
  `mapping` / `arrowmapping` subpackages; the bindings dependency; the
  user-facing bug-report URL; docs/examples/CI.
- **Driver names:** registered under both `"haybarn"` (preferred) and `"duckdb"`
  (drop-in alias) in `duckdb.go`'s `init()`.
- **Preserved (do NOT rename):** the Go package name `duckdb`, the internal
  `"duckdb_api"` config string, and the C/ABI surface (via the bindings).
  Historical references to upstream issue numbers in comments stay as-is.

## Rolling to a new engine version

1. Bump `haybarn-go-bindings` (root + 5 `lib/*` indirect requires) in `go.mod` to
   the new `v0.105NN.x`; `go mod tidy`.
2. Update `HAYBARN_VERSION` in `Makefile` and the version note in `README.md`.
3. If the bindings expose new C-API surface, wire it through.
4. Tag `v2.105NN.x` and push — the Go module proxy resolves it (no registry
   publish step). NOTE: Go requires bare semver tags, so the org-wide
   `haybarn-v*` tag convention does **not** apply here.

## Verifying it is actually Haybarn

```go
db, _ := sql.Open("haybarn", "")
// SELECT version()  -> v1.5.4
// INSTALL <ext>; LOAD <ext>;  -> fetches from haybarn-extensions.query.farm,
//   verifies against the Haybarn trust root; a DuckDB-signed extension is rejected.
```

## Trademark

Product name is always "Haybarn"; DuckDB appears only descriptively. Keep
`LICENSE` (MIT) verbatim and `NOTICE` accurate.
