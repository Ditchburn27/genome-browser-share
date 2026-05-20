# Gene Annotation

## What this section does

Fetches gene features for the multi-locus gene model row. Tries IGV's loaded annotation tracks first, falls back to parsing a local GTF/GFF annotation file directly.

## Key functions

### `mlFetchGeneFeatures(locus) → Feature[]`

Cache key: `locus.chr`. Caches the full chromosome's features in `mlGeneFeatureCache[chr]` then filters to the locus range. Cache entries are evicted from loci not currently in `mlState.loci` at the start of each `mlRender()`.

Resolution order:
1. Walk `igvBrowser.trackViews` looking for tracks with `type === 'annotation'` or `type === 'gene'`, or config format `gtf`/`gff3`/`gff`. Calls `t.getFeatures(chr, 0, 300000000)` to get all features for the chromosome.
2. If IGV yields nothing, parse `sessionData.referenceFiles.annotation` via `mlParseAnnotationFile()`.

### `mlParseAnnotationFile(file, format, chr, start, end) → Feature[]`

Reads the annotation file text and produces transcript feature objects. Parses both GTF and GFF3.

**GTF**: collects `transcript`/`mRNA` records as parent features, aggregates exons by `transcript_id`.  
**GFF3**: uses `ID`/`Parent` attributes to link exons to transcripts.

Returns `Object.values(transcripts)` — one entry per transcript/gene ID, each with `{ chr, start, end, strand, name, exons: [{start, end}] }`.

Attribute extraction uses a regex: `key[= ]"?([^";\t]+)"?` — handles both GTF (`key "value"`) and GFF3 (`key=value`) formats.

### `mlToggleGeneVisibility(locusIdx, geneName, isVisible)`

Updates `mlState.loci[locusIdx].hiddenGenes`. Features matching hidden gene names are filtered out before rendering in `mlRender()` (before computing `sharedNRows` and before drawing).

## Feature shape

```js
{
  chr: "chr7",
  start: 31376000,  // 0-based
  end: 31418000,
  strand: "+",
  name: "NEUROD6",
  exons: [{ start, end }, ...]
}
```

## Gene model drawing

`mlDrawGeneModelSVG(svg, locus, features, sharedNRows)`:

1. Merges transcripts of the same gene by name (union of exon extents).
2. Greedy row packing with label width accounted for (measured on off-screen canvas).
3. Draws: backbone line, exon rectangles, directional arrows, gene name label.

`mlComputeGeneRows(locus, features, cssW, gfs, ff)` is a dry run of the same packing logic, returning only the row count. Used to compute `sharedNRows` across all loci before drawing.

## Interfaces

- Called by `mlRender()` from **multilocus-rendering.md**.
- Reads `igvBrowser.trackViews` from **igv-integration.md**.
- Reads `sessionData.referenceFiles.annotation` from **session-state.md**.
- `mlGeneFeatureCache` is a module-level object; it persists across renders.
