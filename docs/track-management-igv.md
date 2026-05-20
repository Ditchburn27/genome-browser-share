# Track Management (IGV View)

## What this section does

The `#trackControls` panel below the IGV container lets users rename tracks, change colours (via picker or hex input), adjust per-track height, toggle track visibility, select multiple tracks to assign autoscale groups, and drag-reorder. It also manages autoscale group definitions including optional manual Y-range, and gene annotation track position/height controls.

## Key functions

### `renderTrackControls()`
Rebuilds the entire `#trackList` DOM from `sessionData.tracks`. Each track item contains:
- Visibility toggle (👁/🙈 icon, calls `toggleTrackVisibility()`)
- Drag handle (enabled on mousedown so the item isn't draggable by default)
- Checkbox (shift-click range select)
- Color picker
- Hex color text input (monospace, validates `#RRGGBB`)
- Name input
- Height input (px)
- Group badge

Hidden tracks (`visible === false`) get the `.track-hidden` class (dimmed appearance).

### `renderGroupList()`
Rebuilds `#groupList`. Each group card has a name input, track count, remove button, and a Y-range row (checkbox to enable, min/max inputs, Apply button).

### Autoscale groups

**Assignment**: Select tracks → choose group from `#groupAssignSelect` → `assignSelectedToGroup()`. Calls `applyGroupYRangeToIGV()` for the new and any vacated groups.

**Y-range**: `updateGroupYRange(groupName)` reads min/max from the DOM, stores in `sessionData.autoscaleGroupSettings`, then calls `applyGroupYRangeToIGV()`.

**`applyGroupYRangeToIGV(groupName)`**: For each wig track in the group: removes the existing IGV track view, re-loads it via `buildIgvTrackConfig()` (which now sees the updated settings), then calls `syncIGVTrackOrder()`. This is the only reliable way to change IGV autoscale settings on a live track.

### Drag-reorder

Track items set `draggable=true` only while the mouse is down on the handle (mousedown/mouseup), preventing accidental drags from text inputs. On drop, `reorderTrack(fromIndex, toIndex)` splices `sessionData.tracks`, updates `selectedTracks` indices, and calls `syncIGVTrackOrder()` then `reapplyTrackVisibility()`.

### Selection

`handleTrackSelect(event, index)`: shift-click extends selection from `lastClickedIndex`. `selectedTracks` is a `Set<number>` of track indices. `updateSelectionToolbar()` shows/hides `#selectionToolbar` and populates the group dropdown.

### CSV import

`parseCSV(text)` is a hand-rolled parser supporting quoted fields. Header aliases let columns be named `color`, `colour`, or `hex color`. Matching is by exact filename then basename. After applying, calls `igvBrowser.updateViews()` to repaint without reloading tracks.

### `saveSessionConfig()`
Exports the current `sessionData` as `config.json`. Uses `igvBrowser.currentLoci()` for the region field if the browser is live. Includes `geneAnnotation` settings and per-track `visible` field. Alerts with sharing instructions; custom genomes get a different message reminding the user to include reference files.

### Track visibility

**`toggleTrackVisibility(index)`**: Flips `track.visible` and hides/shows the corresponding IGV track view elements via `_hideTrackView()`. Re-renders the track controls list.

**`reapplyTrackVisibility()`**: Walks all tracks with `visible === false` and hides their IGV track view elements via `_hideTrackView()`. Called after `launchBrowser()`, `syncIGVTrackOrder()`, and `reorderTrack()` to maintain hidden state across DOM rebuilds.

**`_hideTrackView(tv, hide)`**: Internal helper that sets `display: none`/`''` on the track view's `axis`, `viewports[].$viewport`, `dragHandle`, `gearContainer`, `innerScroll`, and `outerScroll`. Directly manipulating `trackDiv` does not reliably hide an IGV track—multiple child containers must be toggled.

### Hex color input

**`handleHexInput(index, value)`**: Validates `#RRGGBB` format (auto-prepends `#` if missing). On invalid input, reverts to the current color and flashes the `.invalid` CSS class for 1.5 s. On valid input, calls `updateTrackColor()`.

### Gene annotation controls

Shown in the browser header bar when a gene annotation track is found (works for both preset and custom genomes). Hidden otherwise.

**`showGeneAnnotationControls()`**: Toggles `#geneAnnotationControls` visibility. Syncs the position select, custom position input, and height input to `sessionData.geneAnnotation`.

**`onGenePositionChange(value)`**: Sets position to `'first'`, `'last'`, or shows the custom numeric input.

**`onGeneCustomPositionChange(position)`**: Clamps to 1..(tracks.length+1), stores as string in `sessionData.geneAnnotation.position`.

**`onGeneHeightChange(height)`**: Clamps to 20–400 px, stores in `sessionData.geneAnnotation.height`, applies to the gene track view.

**`applyGeneAnnotationPosition()`**: Sets `.order` on the gene track's IGV view: `500` for first, `maxDataOrder + 100` for last, or `1000 + pos - 0.5` for custom positions (fractional order inserts between data tracks). Calls `igvBrowser.reorderTracks()` and `reapplyTrackVisibility()`.

**`findGeneAnnotationTrackView()`**: Two-pass search for the gene annotation track. First checks for a track named `'Gene Annotations'` (custom genomes); falls back to any IGV annotation/gene track that isn't a ruler/ideogram/sequence and isn't one of the user's data tracks (preset genomes). Returns `null` if neither is found.

## Gotchas

- Group rename updates `sessionData.autoscaleGroupSettings` key and all `track.autoscaleGroup` references, plus matching IGV `trackViews`. This is kept in sync manually—no single source of truth for the group name.
- `applyGroupYRangeToIGV` skips BED tracks (`format !== 'bed'`) since they don't have a Y-axis.
- `updateAllTrackHeights` starts the loop at index 1 to skip the IGV ruler track, and skips the gene annotation track (found via `findGeneAnnotationTrackView()`) since it has independent height control. `updateSingleTrackHeight` uses name-based lookup so it's unaffected.
- `renderTrackControls()` now uses `escHtml()` on track names and group badge text to prevent XSS from user-supplied strings.

## Interfaces

- Reads/writes `sessionData.tracks`, `sessionData.autoscaleGroups`, `sessionData.autoscaleGroupSettings`.
- Calls `buildIgvTrackConfig()` and `syncIGVTrackOrder()` from **igv-integration.md**.
- After track changes, calls `mlSyncTracksFromSession()` to propagate to **multilocus-state.md**.
