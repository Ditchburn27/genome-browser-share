# Utilities

## What this section covers

Small helper functions that are used across multiple sections and don't belong to any single feature.

## Functions

### `escHtml(s)`
Escapes `&`, `<`, `>`, `"` for safe injection into `innerHTML`. Used whenever user-supplied strings (track names, filenames) are rendered into HTML.

### `isRemoteUrl(value)`
Returns `true` if `value` is a string starting with `http://` or `https://` (case-insensitive). Used to distinguish remote track URLs from local filenames in `getTrackSource()`.

### `normalizeTrackConfig(track)`
Called when loading tracks from `config.json`. Ensures `file`, `autoscaleGroup`, `height`, and `visible` fields are always present (coalescing `url` → `file`, null defaults, `visible` defaults to `true`).

### `parseLocusString(str)`
Parses `"chr7:31,376,000-31,418,000"` → `{ chr, start, end }`. Returns `null` if the format doesn't match. Used in locus manager and `mlSeedCurrentLocus()`.

### `fmtBp(n)`
Human-readable base-pair count: `>= 1e6` → Mb (2 decimal places), `>= 1000` → kb (0 decimal places), otherwise bp.

### `fmtCoord(n)`
Formats a genomic coordinate with locale-aware thousands separators (`toLocaleString('en-US')`).

## Object URL management

```js
const _objectURLs = new Set();
mkObjectURL(blob)       // create + track
revokeAllObjectURLs()   // bulk revoke on session teardown
```

Every `URL.createObjectURL()` call in the app must go through `mkObjectURL()`. This is a contract—violating it means URLs leak when the user returns to setup.

## Conventions

- `escHtml` is called whenever user-controlled strings enter `innerHTML`. Do not skip it for "trusted" filenames—they come from the filesystem and can contain `<` or `>`.
- `isRemoteUrl` is the authoritative check for remote vs local. Do not replicate the regex elsewhere.
- `parseLocusString` is lenient about comma separators but strict about the `chr:start-end` structure. It does not validate that start < end.
