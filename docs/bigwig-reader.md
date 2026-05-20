# BigWig Binary Reader

## What this section does

A pure-JavaScript BigWig file parser built on the File API. Used exclusively by the multi-locus view; IGV.js handles its own BigWig reading. Reads directly from `File.arrayBuffer()` without any server round-trip.

## Why it exists

The multi-locus canvas renderer needs raw binned values to paint bar charts. IGV.js doesn't expose its parsed signal values; it only renders to its own DOM. A custom reader was necessary.

## Entry point

```js
readBigWigLocus(file, chr, start, end, nBins) → Float32Array | null
```

`file._abCachePromise` caches the `arrayBuffer()` call—the same file is read many times across loci and re-fetching the buffer each time would be slow.

## Algorithm

1. Read and validate BigWig magic (`0x888FFC26` LE or `0x26FC8F88` BE).
2. Parse fixed header: `version`, `zoomLevels`, `chromTreeOffset`, `fullDataOffset`, `fullIndexOffset`, `uncompressBufSize`.
3. Look up `chromId` for `chr` via B+ tree at `chromTreeOffset`. If not found, retries with/without `chr` prefix.
4. Choose resolution: if zoom levels exist and the ideal resolution (`rangeSize / nBins`) has a matching zoom level, use it; otherwise use full-resolution data.
5. Read full-resolution or zoom data → `Float32Array(nBins)` of averaged signal values.
6. If full-resolution yields all zeros, fall back to zoom data.

## Tree structures

### B+ tree (`getChromId`, `searchBpTree`)
Chromosome name → chromosome ID mapping. Located at `chromTreeOffset`. Nodes: leaf nodes contain `(key, chromId, chromSize)` tuples; internal nodes contain `(key, childOffset)` tuples. Binary search via sorted keys.

### R-tree (`readRTree`, `searchRTree`)
Spatial index of data blocks. Magic: `0x2468ACE0`. Leaf nodes emit `{ offset, size }` data block descriptors; internal nodes recurse. Overlap check uses `(startChromIx, startBase, endChromIx, endBase)` bounding boxes. Blocks that don't overlap `[chromId, start, end]` are skipped.

## Data reading

### `readFullData(ab, dv, le, indexOffset, chromId, start, end, nBins, isCompressed)`
Reads wiggle sections (section types 1=bedGraph, 2=varStep, 3=fixedStep). Accumulates signal into `nBins` bins using weighted averaging. Returns `Float32Array(nBins)`.

### `readZoomData(ab, dv, le, indexOffset, chromId, start, end, nBins, isCompressed)`
Reads zoom-level records (32-byte structs: chromId, start, end, nVals, min, max, sumData, sumSq). Uses `sumData / nVals` as the mean. Applies linear interpolation to fill zero-count bins between two non-zero bins.

### `decompressBlock(ab, offset, size, isCompressed)`
Tries `deflate` then `deflate-raw` via the `DecompressionStream` API. Falls back to uncompressed slice if both fail. This covers the different zlib framing conventions used by various BigWig producers.

## Limitations

- Only reads local `File` objects. Remote URLs (http/https) are not supported—use IGV for those.
- Does not handle wiggle type 0 (BED-style) explicitly; it's treated as type 1.
- No BigBed support.
- Very large files are fully buffered in memory on first access.
- Chromosome alias normalisation is limited to `chr`↔no-`chr` prefix swap.

## Interfaces

- Called by `mlRender()` (pass 5) from **multilocus-rendering.md**.
- Also called directly by `mlPaintTrack()` for on-demand single-cell fetches.
- `file._abCachePromise` is a monkey-patched cache on the `File` object—not part of any interface but important to preserve when working with file references.
