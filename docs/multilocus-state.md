# Multi-Locus State & Configuration

## What this section does

`mlState` is the complete state for the multi-locus figure view. This section covers initialisation, syncing with `sessionData`, and saving/loading the ML config file.

## `mlState` key fields

| Field | Default | Purpose |
|---|---|---|
| `loci` | `[{ id:1, gene:'LOCUS 1', chr:'', start:0, end:0, raw:'', hiddenGenes:[] }]` | Ordered list of genomic windows (columns in the figure) |
| `tracks` | `[]` | Projection of `sessionData.tracks` with extra ML-specific fields |
| `trackHeight` | 70 | Canvas height in px for each track row |
| `yscale` | `'auto'` | Y-scale mode: `auto`, `row`, `group`, `group-row`, `global`, `browser` |
| `activeTagFilters` | `new Set()` | Tag values currently used to filter visible tracks |
| `nBins` | 300 | Bin count passed to BigWig reader |
| `tagCategoryDefs` | `{}` | `{ catName: [value1, value2, ...] }` — master list of allowed values per category |
| `tagCategoryColors` | `{}` | `{ catName: { value: "#hex" } }` — colours used in legend/squares |
| `tagCategoryOrder` | `[]` | Ordered array of category names for display |
| `manualYmax` | `{}` | Per-track manual Y-max overrides (stored on `mlState.tracks[i].manualYmax`) |
| `browserYmax` | `{}` | Snapshot of IGV's current Y-max per track (set via `mlUseCurrentView()`) |

## `mlState.tracks` shape

```js
{
  name,           // mirrors sessionData.tracks[i].name
  color,          // starts from sessionData; can diverge in ML view
  visible,        // toggle in sidebar
  file,           // File object | null (for local BigWig)
  sourceUrl,      // string | null (for remote tracks)
  autoscaleGroup, // mirrors sessionData
  tags,           // flat array—derived from Object.values(tagCategories)
  tagCategories,  // { catName: value }
  cache,          // reserved (unused currently)
  manualYmax,     // number | null
}
```

`tags` is always `Object.values(tagCategories)` after any category operation. It's kept for legacy compatibility; filtering uses `tagCategories` values.

## `mlSyncTracksFromSession()`

Called on every tab switch to multi-locus and after tracks are added live. Merges by name:
- Existing `mlState.tracks` entries: preserve `color`, `visible`, `tags`, `tagCategories`, `manualYmax`; update `file`, `sourceUrl`, `autoscaleGroup` from session.
- New tracks in session: create fresh entries with `visible: true`, empty tags.
- Removed tracks in session: dropped (array is rebuilt from `sessionData.tracks` order).

## Save / Load ML Config

### `mlSaveConfig()`
Serialises `mlState.loci`, per-track settings (`name`, `color`, `visible`, `tags`, `tagCategories`, `manualYmax`), and the full `settings` object. Downloads as `ml_config.json`.

### `mlLoadConfigFromFile(input)` / `mlApplyConfig(config)`
`mlApplyConfig` restores loci and settings. Track settings are matched by `name`; unmatched names are skipped (tolerant of renamed or missing tracks). It calls `setIfDef` for each UI control to sync the DOM to the restored state.

**Legacy migration**: old flat `tags` arrays are migrated to `tagCategories` on load if `tagCategories` is empty.

Auto-apply on tab switch: if `sessionData.mlConfig` is set and `sessionData.mlConfigApplied` is false, `switchTab('multilocus')` calls `mlApplyConfig` once and sets the flag.

## Tag system

Tags are structured as `tagCategories: { "Modality": "ATAC", "Condition": "treated" }`. Categories are defined globally in `tagCategoryDefs` and ordered in `tagCategoryOrder`. Operations:

- `mlTagAddCategory()` — prompts for name, adds to `tagCategoryDefs` and `tagCategoryOrder`.
- `mlTagAddValue(cat, val)` — adds a value to `tagCategoryDefs[cat]`.
- `mlTagRenameCategory(old, new)` — renames everywhere: `tagCategoryOrder`, `tagCategoryDefs`, `tagCategoryColors`, all track `tagCategories`.
- `mlAddTagCategory(i, cat, val)` — sets `mlState.tracks[i].tagCategories[cat] = val`.
- `mlTagAssignToSelected()` — batch-assigns the selected category:value to all checked tracks.

## Interfaces

- Reads `sessionData.tracks` via `mlSyncTracksFromSession()`.
- `mlState` is the sole input to **multilocus-rendering.md** (`mlRender()`).
- Tag colours feed into **multilocus-ui.md** (sidebar, style panel, legend).
- `mlUseCurrentView()` reads `igvBrowser.referenceFrameList` — see **igv-integration.md**.
