# CLAUDE.md — haybarn-go (2.0 line)

Guidance for Claude Code (and humans) working in this repository.

## What this repo is

The `database/sql` driver for **Haybarn** (Query Farm LLC's independent derived
distribution of DuckDB). Hard fork of `duckdb/duckdb-go`, sitting on top of
[`haybarn-go-bindings`](https://github.com/Query-farm-haybarn/haybarn-go-bindings).
A thin layer over the bindings — most of the engine and all "Haybarn-ness" live
below, in `libhaybarn_static.a` inside the bindings' native modules.

Branches: `haybarn` is the 1.5 line; `haybarn-2.0` is the 2.0 line (this
file), a clean import of upstream tag `v2.20000.0` plus a curated Haybarn stack.

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

1. Bump `haybarn-go-bindings` in `go.mod` to the new `v0.200NN.x` (or a
   pseudo-version of a bindings branch commit before it is tagged);
   `go mod tidy` — with `eval "$(scripts/native-proxy.sh)"` first if the
   bindings' native modules aren't published yet.
2. If the bindings expose new C-API surface, wire it through.
3. Tag `v2.200NN.x` (`-rc.N` for engine RCs) and push — the Go module proxy
   resolves it. Go requires bare semver tags, so the org-wide `haybarn-v*`
   convention does **not** apply. Tag only after the bindings tag and their
   native modules are published.

## Verifying it is actually Haybarn

```go
db, _ := sql.Open("haybarn", "")
// SELECT version()  -> v2.0.0
// INSTALL <ext>; LOAD <ext>;  -> fetches from haybarn-extensions.query.farm,
//   verifies against the Haybarn trust root; a DuckDB-signed extension is rejected.
```

## Trademark

Product name is always "Haybarn"; DuckDB appears only descriptively. Keep
`LICENSE` (MIT) verbatim and `NOTICE` accurate.
