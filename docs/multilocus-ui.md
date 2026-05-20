# Multi-Locus UI

## What this section does

Covers the sidebar (track list + tags), locus manager modal, figure style panel, and colour picker. These components mutate `mlState` and trigger `mlRender()`.

## Sidebar (`#mlClusterList`)

Rendered by `mlRenderSidebar()`. One row per `mlState.tracks[i]`:
- Checkbox for batch tag assignment (`mlState.mlTagSelectedTracks`)
- Visibility toggle (👁/🙈 → `mlToggleTrack(i)`)
- Track name + category:value tag pills
- Colour swatch → opens HSL colour picker

`mlRenderTagSelectionBar()` renders the `#mlTagSelBar` when tracks are selected. Populated with category and value dropdowns from `tagCategoryDefs`. "Assign" calls `mlTagAssignToSelected()`.

`mlRenderTagFilters()` renders the filter pills in `#mlTagFilterRow`. Active filters are stored in `mlState.activeTagFilters` (Set of tag values). Tracks not matching any active filter are hidden from `mlRender()`.

`mlRenderTagCategoryDefs()` renders the `#mlTagCategoryDefs` panels—one collapsible card per category with value rows, a delete button, and an add-value form. Category names are editable inline (`contenteditable`).

## Locus Manager Modal

`openLocusManager()` opens `#locusManagerOverlay` and calls `renderLocusManagerList()`. Each locus item shows:
- Drag handle (same drag pattern as track list)
- Label input
- Coord input (monospace, parses on `change` via `mlUpdateLocusCoord()`)
- "Visible Genes" checkbox list (genes fetched via `mlFetchGeneFeatures()`)

`mlAddLocus()` requires coordinates; gene name is optional (falls back to the coord string). `mlUseCurrentView()` fills the coord input from IGV's current viewport.

`mlUpdateLocusCoord(i, val)` re-parses, updates `mlState.loci[i]`, clears `hiddenGenes`, and re-renders the locus list (to refresh gene checkboxes).

## Figure Style Panel (`#mlStylePanel`)

Fixed-position panel toggled by `mlToggleStylePanel()`. Controls map directly to `mlState` fields:
- Show/Hide checkboxes
- Typography sliders (font size per element type)
- Gene model colours and display mode
- Label style and legend options
- Export size controls
- Track Colours section (see below)

**Track Colours section**: `mlRefreshStylePanelTrackColors()` builds the `#mlStyleTrackColors` list. Each row has a checkbox, colour swatch (opens HSL picker), name, tag summary, and hex input. The hue-shift panel applies a hue at a given saturation/lightness to all checked tracks, with lightness spread across multiple selected tracks.

`mlAutoColorByTag()` assigns colours from the 16-colour palette to tag values in the first category, then sets each track's colour to match its value in that category.

## HSL Colour Picker

A floating `#mlColorPicker` div (fixed position). Opened by `mlColorPickerOpen(trackIdx, anchorEl)`. Contains three range sliders (H, S, L) and a hex input. `mlCpickUpdate()` keeps the preview swatch and hex field in sync. `mlColorPickerApply()` calls `mlSetTrackColor()`.

`mlHsUpdateChips()` renders the hue chip palette in the style panel's hue-shift tool (16 predefined hues at the current sat/lightness).

## Colour utilities

```js
hslToHex(h, s, l)   // h: 0-360, s/l: 0-100 → "#rrggbb"
hexToHsl(hex)        // → { h, s, l }
```

Used by the HSL picker and hue-shift tools. The formula uses the standard HSL-to-RGB conversion via the `f(n)` helper inside `hslToHex`.

## Interfaces

- All mutations go through `mlState` → triggers `mlRender()` from **multilocus-rendering.md**.
- Tag operations call `mlRenderLegendColorEditor()`, `mlRenderCatLabelToggles()`, `mlRenderTagFilters()` to keep subsidiary UI in sync.
- Locus manager calls `mlFetchGeneFeatures()` from **gene-annotation.md** to populate gene checkboxes.
- `mlRenderSidebar()` also calls `mlRefreshStylePanelTrackColors()` and `mlRenderTagCategoryDefs()` so the style panel stays in sync with track list changes.
