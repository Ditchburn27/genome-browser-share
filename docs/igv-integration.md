# IGV Browser Integration

## What this section does

Creates and manages the IGV.js browser instance (`igvBrowser`). Translates `sessionData` into IGV config format, syncs track state changes back to the live browser, and handles keyboard navigation.

## Key functions

### `launchBrowser()`
The single point that creates `igv.createBrowser()`.

Flow:
1. Builds `igvOptions` (`genome` or `reference`, `locus`, `tracks`).
2. Calls `buildReferenceConfig()` for custom genomes.
3. Converts each resolvable track via `buildIgvTrackConfig()` and pushes to `igvOptions.tracks`.
4. Hides `#setupView`, shows `#browserView`.
5. Creates the IGV instance; wires up mouse/wheel listeners to blur focused inputs after pan/zoom (prevents arrow-key conflicts).
6. Calls `renderTrackControls()`, `renderGroupList()`, `updateGroupCountDisplay()`, `reapplyTrackVisibility()`, `showGeneAnnotationControls()`, and applies gene annotation position/height.

Tracks without a resolvable source (local file not provided, not a remote URL) are silently skipped. `sessionData.trackViewIndices` records which `sessionData.tracks` indices were actually loaded.

### `buildIgvTrackConfig(track, source)`
Converts a `sessionData` track + resolved source into an IGV track config object.

- Detects BEDPE vs BED vs BigWig by `format` field and file extension.
- BEDPE → `type: 'interaction'`, `format: 'bedpe'`, `height: 200`.
- BED → `type: 'annotation'`, `displayMode: 'COLLAPSED'`.
- BigWig → `type: 'wig'`, `autoscale: true`, unless the track's autoscale group has manual Y-range settings, in which case `autoscale: false` with explicit `min`/`max`.
- Local files get `url: mkObjectURL(source.file)`.

### `getTrackSource(track)`
Returns `{ kind: 'remote', url }` or `{ kind: 'local', file }` or `null`. Remote if the file field is an http(s) URL; local if the filename resolves in `sessionData.bigWigFiles`; null otherwise.

### `syncIGVTrackOrder()`
Writes `.order` to each IGV track view (offset by 1000 so they sort after ruler/gene tracks) then calls `igvBrowser.reorderTracks()`. Also calls `applyGeneAnnotationPosition()` to reposition the gene track. Called after drag-reorder in the track controls UI.

### `updateTrackColor(index, color)`
Updates `sessionData.tracks[index].color` and calls `tv.repaintViews()` on the matching IGV track view. Name-based lookup—assumes track names are unique. Bidirectionally syncs the color picker and hex input in the track controls UI.

### `updateTrackName(index, name)`
Same pattern as `updateTrackColor`. Stores old name before changing so the lookup still works.

### `updateAllTrackHeights(height)` / `updateSingleTrackHeight(index, height)`
Calls `tv.setTrackHeight()` on matching IGV track views. Skips index 0 (ruler track) and skips the "Gene Annotations" track (which has independent height control).

### `exportImage()`
Calls `igvBrowser.toSVG()` and downloads the result. Filename includes the current locus.

### `backToSetup()`
Calls `igvBrowser.removeAllTracks()`, revokes all object URLs, resets `sessionData` and `igvBrowser` to null, restores the setup view.

## Keyboard navigation

Arrow keys pan the IGV view by 20% of the current span. Implemented via a capturing `keydown` listener on `window`. Skips if the focused element is inside `#trackControls` or is a `<select>`.

Uses `igvBrowser.referenceFrameList[0]` for direct coordinate math (more reliable than parsing the locus string), falling back to string parsing.

## Gotchas

- `igvBrowser.trackViews` includes the ruler and gene annotation tracks before data tracks. Code that iterates `trackViews` and starts from index 1 (e.g., `updateAllTrackHeights`) is skipping the ruler intentionally.
- The gene annotation track height is controlled independently via `sessionData.geneAnnotation.height` and the `#geneHeightInput` control, not the global "All Heights" input. `updateAllTrackHeights` skips it via `findGeneAnnotationTrackView()`.
- IGV autoscale groups are set via `igvTrack.autoscaleGroup` at load time. Changing group membership requires removing and re-loading the track (`applyGroupYRangeToIGV`).
- The `currentLoci()` call can return either a string or an array depending on whether split-view is active; all code that reads it uses `Array.isArray(lociResult) ? lociResult[0] : lociResult`.

## Interfaces

- Reads `sessionData` from **session-state.md**.
- Calls `buildReferenceConfig()` from **genome-reference.md**.
- Triggers `renderTrackControls()` from **track-management-igv.md**.
- `mlUseCurrentView()` reads `igvBrowser.referenceFrameList` to seed multi-locus loci.
