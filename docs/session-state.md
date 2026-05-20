# Session State & Global Variables

## What this is

All runtime state lives in two top-level objects and a handful of module-level vars. There is no module system—everything is `let`/`const` at script scope.

## Key globals

| Name | Type | Purpose |
|---|---|---|
| `igvBrowser` | IGV.js instance | The live IGV browser. `null` until `launchBrowser()` resolves. |
| `sessionData` | Object | Source of truth for genome, locus, tracks, local files, and autoscale groups. |
| `mlState` | Object | Source of truth for the multi-locus view—loci, rendering options, track colours, tags. |
| `selectedTracks` | Set\<number\> | Indices into `sessionData.tracks` currently checked in the track controls UI. |
| `dragSourceIndex` | number|null | Index of the track being dragged in the IGV track list. |
| `locusDragSourceIndex` | number|null | Index of the locus being dragged in the locus manager modal. |

## `sessionData` shape

```js
{
  genome: "hg38" | "custom:<id>",
  locus: "chr17:7,661,779-7,687,550" | null,
  tracks: [{ name, file, color, type, format, autoscaleGroup, height, visible }],
  bigWigFiles: { "filename.bw": File, "path/filename.bw": File },
  autoscaleGroups: ["Group 1", "Group 2"],
  autoscaleGroupSettings: { "Group 1": { yMin: 0, yMax: 4 } },
  referenceFiles: { fasta: File, index: File|null, annotation: File|null, annotationFormat: "gtf"|"gff3" } | null,
  pendingRefFiles: File[] | null,
  mlConfig: Object | null,       // parsed ml_config.json, applied once on tab switch
  mlConfigApplied: boolean,
  geneAnnotation: { position: 'first'|'last'|string, height: number },
}
```

`tracks[].visible` defaults to `true`. When `false`, the IGV track view's DOM elements (axis, viewports, drag handle, gear container, scroll areas) are hidden via `_hideTrackView()` and the track list row gets the `.track-hidden` class (dimmed appearance).

`geneAnnotation` controls the position and height of the "Gene Annotations" track in IGV. `position` can be `'first'`, `'last'`, or a numeric string for a custom insertion index. Persisted through config.json save/load.

`bigWigFiles` is keyed by both `file.name` and `file.webkitRelativePath` so config.json references using either form resolve correctly.

## Object URL tracking

```js
const _objectURLs = new Set();
function mkObjectURL(blob) { ... }  // create + register
function revokeAllObjectURLs() { ... }  // call on backToSetup()
```

All `URL.createObjectURL()` calls go through `mkObjectURL()`. This prevents leaks when the user navigates back to setup. IGV requires object URLs for local files; they must remain live for the browser's lifetime.

## `mlState` shape (abbreviated)

```js
{
  loci: [{ id, gene, chr, start, end, raw, hiddenGenes }],
  tracks: [{ name, color, visible, file, sourceUrl, autoscaleGroup, tags, tagCategories, cache, manualYmax }],
  trackHeight, yscale, showGene, showYmax, showLabels, showBorder,
  activeTagFilters: Set<string>,
  // typography
  fontFamily, fontSizeGeneName, fontSizeCoord, fontSizeTrackLabel, fontSizeYmax,
  // gene model
  geneModelColor, geneExonColor, geneLabelColor, geneModelMode,
  // export
  exportColW, exportScale,
  // label/legend
  labelStyle, squareSource, showLegend, tagCategoryColors, tagCategoryOrder,
  tagCategoryDefs, catLabelsEnabled, catLabelColor, fontSizeCatLabel,
  // y-scale
  browserYmax, manualYmax, ymaxMode,
}
```

`mlState.tracks` is kept in sync with `sessionData.tracks` via `mlSyncTracksFromSession()`, which merges colour/visibility/tag state onto a fresh projection of the session tracks.

## Interfaces with other sections

- **Setup / file handling** writes into `sessionData` before `launchBrowser()`.
- **IGV integration** reads `sessionData.tracks`, `sessionData.bigWigFiles`, and `sessionData.genome`.
- **Track management UI** reads/writes `sessionData.tracks` and `sessionData.autoscaleGroups`.
- **Multi-locus rendering** reads `mlState` exclusively; `mlSyncTracksFromSession()` is the bridge from `sessionData`.
