# CLAUDE.md

The app is a single-file web application (`site/index.html`) for visualising and sharing BigWig/BED/BEDPE genomic data. It has no build step, no bundler, and no backend. All CSS, JavaScript, and HTML live in one file. IGV.js v2.15.8 is loaded from CDN. The app is deployed as a static site on Cloudflare Pages from the `site/` directory.

There are two main runtime contexts: the IGV Browser tab (IGV.js renders tracks natively) and the Multi-Locus Figure tab (a custom BigWig reader paints HTML canvas cells, gene models are SVG). State for the two contexts is kept in `sessionData` (IGV side) and `mlState` (multi-locus side), bridged by `mlSyncTracksFromSession()`.

The entire application state for a session is serialisable to `config.json` (track list + genome + locus) and `ml_config.json` (multi-locus loci, track tags/colours, rendering settings). Users share sessions by sharing these JSON files alongside their data files.

## Deployment

- **Host**: Cloudflare Pages, static serving of `site/`.
- **No server-side logic**: all file I/O is via the browser File API (drag-drop, `<input type="file">`).
- **Custom genomes via HTTP**: reference files served as static assets from `site/references/`; manifest at `site/references/manifest.js`.
- **Custom genomes on file://**: user must drag-drop FASTA/FAI/GTF; `references/manifest.js` paths don't work under `file://`.
- To test locally: `python -m http.server` from project root, open `http://localhost:8000/site/`.

## Documentation index

@docs/session-state.md — `sessionData`, `mlState`, object URL tracking, global vars
@docs/setup-and-file-handling.md — drag-drop, `processFiles()`, `createNewSession()`, CSV import, `addTracksFromFiles()`
@docs/genome-reference.md — preset vs custom genomes, `buildReferenceConfig()`, `manifest.js`, reference file prompt
@docs/igv-integration.md — `launchBrowser()`, `buildIgvTrackConfig()`, track sync, keyboard nav, `exportImage()`
@docs/track-management-igv.md — track controls UI, autoscale groups, Y-range, reorder, `saveSessionConfig()`
@docs/multilocus-state.md — `mlState` fields, `mlSyncTracksFromSession()`, tag system, save/load ML config
@docs/multilocus-rendering.md — `mlRender()` pipeline, Y-scale modes, `mlPaintTrack()`, `mlExportSVG()`
@docs/bigwig-reader.md — custom BigWig parser (B+ tree, R-tree, decompression, zoom data)
@docs/gene-annotation.md — `mlFetchGeneFeatures()`, GTF/GFF parser, `mlDrawGeneModelSVG()`, gene packing
@docs/multilocus-ui.md — sidebar, locus manager, figure style panel, HSL colour picker, tag UI
@docs/utilities.md — `escHtml()`, `hslToHex()`, `hexToHsl()`, `parseLocusString()`, `fmtBp()`, object URL helpers

## Before you touch X, read docs/Y.md

| What you're changing | Read first |
|---|---|
| File loading, drag-drop, config.json parsing | docs/setup-and-file-handling.md |
| Custom genome / FASTA / FAI / GTF support | docs/genome-reference.md |
| IGV track loading, colors, heights, ordering | docs/igv-integration.md + docs/track-management-igv.md |
| Autoscale groups or Y-range controls | docs/track-management-igv.md |
| Multi-locus canvas rendering or Y-scale modes | docs/multilocus-rendering.md |
| BigWig parsing / signal reading | docs/bigwig-reader.md |
| Gene model drawing or GTF/GFF parsing | docs/gene-annotation.md |
| Tags, tag categories, legend, colour picker | docs/multilocus-ui.md |
| `mlState` fields or ML config save/load | docs/multilocus-state.md |
| `sessionData` shape or object URLs | docs/session-state.md |

## Hard rules

- **Never** call `URL.createObjectURL()` directly — use `mkObjectURL()` so the URL is tracked for revocation.
- **Always** use `escHtml()` before inserting user-supplied strings into `innerHTML` (filenames, track names).
- Track name matching between `sessionData.tracks` and `igvBrowser.trackViews` is done by name — names must be unique within a session.
- IGV's `trackViews[0]` is the ruler track; loops that update track heights or iterate data tracks start at index 1.
- Changing IGV autoscale group settings requires removing and re-loading the track (`applyGroupYRangeToIGV`) — you cannot mutate IGV's min/max in place.
- `mlState.tracks[i].tags` is always `Object.values(tagCategories)` — never set it independently.
- There is no build step. Edit `site/index.html` directly. Test by opening in a browser or via `python -m http.server`.
