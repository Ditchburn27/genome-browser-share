# Setup UI & File Handling

## What this section does

The setup view is the entry point. It collects local files or a config.json and then calls `launchBrowser()`. Two paths exist: **load existing session** (drop folder or files) and **create new session** (manual genome + file picker).

## Key functions

### `processFiles(files: File[])`
Main dispatcher for the drag-drop / folder-select flow.

1. Classifies files into: `configFile`, `mlConfigFile`, `bigWigFiles`, `bedFiles`, `bedpeFiles`, `refFiles`.
2. Calls `parseReferenceFiles()` to extract FASTA/FAI/GTF if present.
3. Parses `config.json` into `sessionData` (including `geneAnnotation` and per-track `visible` fields) or synthesises defaults via `createDefaultTracks()`.
4. Checks for missing tracks (`getTrackSource()` returns null) and warns but does not abort.
5. If a custom genome needs reference files that weren't supplied, calls `showReferenceFilePrompt()` instead of `launchBrowser()`.

### `createNewSession()`
Handles Option 2 (manual). Reads `#genomeSelect`, `#startLocation`, `#bigWigInput`, optionally `#refFastaInput` / `#refFaiInput` / `#refGtfInput`. Writes into `sessionData` then calls `launchBrowser()`.

### `createDefaultTracks(files: File[])`
Generates track configs for files without a config.json. Alternates colours from fixed palettes (`wigColors`, `bedColors`). BEDPE always gets `#CC00CC`. Each track includes `visible: true`. Returns an array of track objects.

### `traverseFileTree(item, files)`
Recursive `webkitGetAsEntry()` walker. Needed because drag-dropped folders only expose entries via the FileSystem API, not `dataTransfer.files`.

### `addTracksFromFiles(files: File[])`
Live-adds tracks into a running IGV session. De-duplicates by filename. On failure, rolls back `sessionData.tracks` and `bigWigFiles`. After success, calls `renderTrackControls()` and optionally re-renders the multi-locus view.

### `parseCSV(text)` / `handleCSVImportSelect()` / `applyCSVImport(rows)`
Imports track names, colours, and autoscale group assignments from a CSV. Matches rows to tracks by `file` field (falls back to basename comparison). Applies changes to both `sessionData` and live `igvBrowser.trackViews`.

## File classification rules

| Extension | Category |
|---|---|
| `.bw`, `.bigwig`, `.bigWig` | BigWig track |
| `.bed` | BED annotation track |
| `.bedpe` | BEDPE interaction track |
| `.fa`, `.fasta`, `.fna`, `.fai`, `.gzi`, `.gtf`, `.gff`, `.gff3` | Reference files |
| `config.json` | Session config |
| `ml_config.json` | Multi-locus config (auto-applied on first ML tab switch) |

## Gotchas

- `bigWigFiles` is keyed by both `file.name` and `file.webkitRelativePath`. Config.json may reference either form depending on how the session was saved.
- `ml_config.json` is loaded into `sessionData.mlConfig` at process time but only applied the first time the Multi-Locus tab is opened (`mlConfigApplied` flag).
- CSV colour values must be exact 6-digit hex (`#RRGGBB`); others are silently skipped.
- The folder input uses `webkitdirectory`, which flattens the tree. Deep paths are preserved in `webkitRelativePath` but the file name is still just the basename.

## Interfaces

- Writes `sessionData` → read by **IGV integration** and **track management**.
- Calls `launchBrowser()` or `showReferenceFilePrompt()` → see **genome-reference.md**.
- Calls `renderTrackControls()` / `renderGroupList()` → see **track-management-igv.md**.
