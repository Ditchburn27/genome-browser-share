# Multi-Locus Rendering Pipeline

## What this section does

`mlRender()` builds the entire multi-locus figure as HTML+canvas, fetches BigWig data in parallel, computes Y-scales, paints each track cell, and (in a `requestAnimationFrame`) draws gene models as SVG.

## Pipeline passes

```
mlRender()
  ├── 1. Filter: visibleTracks, loci with valid coords
  ├── 2. Build HTML grid (header + track rows + gene row stubs)
  ├── 3. Insert HTML into #mlBrowser (replaces previous render)
  ├── 4. [useCatSquares] Overlay category colour bars (rAF)
  ├── 5. Parallel BigWig fetch: binGrid[ti][li]  (BED/BEDPE → null, handled at paint time)
  ├── 6. Compute ymaxGrid[ti][li] by yscale mode
  ├── 7. Apply manualYmax overrides
  ├── 8. Paint canvases (mlPaintTrack for each canvas)
  └── 9. [showGene] Draw gene models in rAF (mlDrawGeneModelSVG)
```

Step 3 happens before step 5—the DOM is ready before data arrives so canvases are correctly sized.

## Y-scale modes

| Mode | Description |
|---|---|
| `auto` | Each cell independent (default) |
| `row` | All loci for a given track share the row max |
| `group` | Tracks in same autoscale group share max per locus column |
| `group-row` | Tracks in same group share max across all loci |
| `global` | Single max across entire figure |
| `browser` | Use `locus.browserYmax[trackName]` captured from IGV at locus-add time |

Manual `track.manualYmax` overrides any computed value as a final step.

## `mlPaintTrack(canvas, ti, li, visibleTracks, loci, preloadedBins, preloadedYmax)`

Dispatches to:
- `mlPaintBedTrack()` — reads BED file text, draws coloured rectangles in stacked rows.
- `mlPaintBedpeTrack()` — reads BEDPE text, draws arcs (`quadraticCurveTo`) from midpoint to midpoint.
- BigWig bar chart — uses preloaded bins from pass 5; draws filled rectangles scaled to `ymax`.

For remote-only tracks (`sourceUrl` set, no local `file`): shows "remote IGV only" message—the BigWig reader only works with local `File` objects.

Canvas width is read from `canvas.offsetWidth` at paint time (not set in HTML), so it matches the actual rendered column width.

## Label column layouts

Three modes controlled by `mlState.labelStyle` and `mlState.squareSource`:

| `labelStyle` | `squareSource` | Layout |
|---|---|---|
| `pill` | — | Right-aligned text + coloured pill bar |
| `square` | `color` | Track-colour square + label text |
| `square` | `tag` | One square per category (overlaid via rAF) + label omitted |

In `useCatSquares` mode, the label column is a spacer in the HTML; the actual coloured blocks are injected as an `absolute`-positioned overlay in a `requestAnimationFrame` after DOM layout. This is necessary because `th` (track height) is not known until the DOM is live.

## Gene model row

`mlDrawGeneModelSVG(svg, locus, features, sharedNRows)` renders directly into SVG elements placed in `.ml-gene-cell` divs. `sharedNRows` is computed first across all loci via `mlComputeGeneRows()` so all gene rows in the figure have the same height.

Gene packing: greedy row assignment using `rowEnds[]` array (earliest row where the gene + label fits). Text width measured with an off-screen canvas 2D context.

Gene display modes (controlled by `mlState.geneModelMode`): squished, collapsed, full, bar, arrows. Currently `squished` is the only mode implemented in `mlDrawGeneModelSVG`; the selector UI exists for all modes but the function always draws exon blocks with backbone.

## `mlExportSVG()`

Produces an SVG string from scratch (not `serialiseToString` of the DOM). Track cells are embedded as PNG `<image>` elements—each canvas is converted via `canvas.toDataURL('image/png')`. Gene model SVGs are embedded inline. Scale factor (`exportScale`) is applied via the SVG `width`/`height` vs `viewBox` relationship.

Category label bars and the legend panel are redrawn from state (not copied from DOM).

## Interfaces

- Reads `mlState` exclusively.
- Calls `readBigWigLocus()` from **bigwig-reader.md**.
- Calls `mlFetchGeneFeatures()` from **gene-annotation.md**.
- `mlPaintBedTrack` / `mlPaintBedpeTrack` read `File.text()` directly—no intermediate parser.
- `mlRender()` is debounced on window resize (200 ms via `clearTimeout`/`setTimeout`).
