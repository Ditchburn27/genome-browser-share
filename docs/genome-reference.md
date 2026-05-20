# Genome & Reference Configuration

## What this section does

Handles the two genome modes—preset (hg38/hg19/mm10/mm39) and custom (any FASTA)—and the multi-step resolution of reference files needed for custom genomes.

## Preset genomes

Passed to IGV as `igvOptions.genome = "hg38"`. IGV resolves gene annotations from UCSC/Ensembl automatically. No local files required.

## Custom genomes

Identified by `sessionData.genome` starting with `"custom:"`. Three resolution sources, tried in order:

1. **`sessionData.referenceFiles`** — user-supplied `File` objects (drag-drop or picker).
2. **`CUSTOM_GENOMES[id]`** — paths declared in `references/manifest.js` (HTTP only).
3. **Neither** — throws `{ code: 'NEEDS_FILE_PICKER', genomeId }`, which triggers `showReferenceFilePrompt()`.

## Key functions

### `buildReferenceConfig(genomeId)`
Returns `{ reference, annotationTrack }` for IGV. The `reference` object has `fastaURL` and optionally `indexURL`. Annotation track (GTF/GFF) is returned separately to be appended to `igvOptions.tracks`; its `height` is sourced from `sessionData.geneAnnotation.height` (falls back to 100). All local files are wrapped via `mkObjectURL()`.

### `parseReferenceFiles(files: File[])`
Classifies a flat file list into `{ fasta, index, annotation, annotationFormat }`. Returns `null` if no FASTA found. Called during `processFiles()` to auto-detect reference files in a dropped folder.

### `showReferenceFilePrompt(genomeId)`
Renders an inline UI (injected into `#uploadStatus`) with drop zone and three file pickers (FASTA, FAI, GTF). Registers `pendingRefPromptSubmit` which `launchWithPromptedRefs()` can call programmatically. On submit, stores into `sessionData.referenceFiles` and calls `launchBrowser()`.

### `needsReferenceFilePrompt(genomeId)`
Returns `true` when: genome is custom AND `sessionData.referenceFiles` is null AND the genome ID is not in `CUSTOM_GENOMES`.

### `populateGenomeDropdown()`
Appends an `<optgroup>` for `CUSTOM_GENOMES` to `#genomeSelect`. Called once at page load. `CUSTOM_GENOMES` is declared as `{}` before `references/manifest.js` loads, so a missing manifest is harmless.

## `references/manifest.js` format

```js
var CUSTOM_GENOMES = {
  "myGenome": {
    label: "My Organism v1",
    fasta: "references/myGenome/genome.fa",
    index: "references/myGenome/genome.fa.fai",
    annotation: "references/myGenome/genes.gtf",
    annotationFormat: "gtf"
  }
}
```

Loaded via `<script>` tag. Must be regenerated with `references/update_manifest.sh` after adding genome subdirectories. Only works under HTTP (file:// cannot load relative paths in IGV); on file:// the user must supply files.

## Config.json genome field

Custom genome IDs are stored with the `custom:` prefix: `"genome": "custom:myGenome"`. This round-trips correctly through save/load.

## Interfaces

- Called by `launchBrowser()` → see **igv-integration.md**.
- Calls `mkObjectURL()` from **session-state.md**.
- File picker prompt writes to `sessionData.referenceFiles` → used again by `buildReferenceConfig()`.
