# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file web application for visualizing and sharing BigWig genomics data using IGV.js. The entire application is contained in `genome-browser-share.html` - there is no build process, bundler, or backend.

## Architecture

**Single HTML file structure:**
- All CSS is inline in `<style>` tags (lines 8-375)
- All JavaScript is inline in `<script>` tags (lines 517-961)
- IGV.js v2.15.8 is loaded from CDN

**Key JavaScript components:**
- `sessionData` object: Stores genome, locus, tracks array, bigWigFiles map, and referenceFiles
- `igvBrowser`: IGV.js browser instance created via `igv.createBrowser()`
- File handling: Uses File API with drag-drop and webkitdirectory for folder uploads
- Track management: Syncs between sessionData.tracks and igvBrowser.trackViews
- Custom genome support: `references/manifest.js` loaded via `<script>` tag sets `CUSTOM_GENOMES` global

**Two-view UI pattern:**
- Setup view (`#setupView`): File upload and session configuration
- Browser view (`#browserView`): IGV visualization with controls

## Key Functions

- `processFiles()`: Parses config.json, BigWig, BED, and reference files, populates sessionData
- `launchBrowser()`: Creates IGV browser instance; uses `genome` for presets or `reference` for custom genomes
- `updateTrackColor()/updateTrackName()`: Syncs UI changes to IGV trackViews by name matching
- `saveSessionConfig()`: Exports current state as config.json
- `buildReferenceConfig()`: Builds IGV.js reference config for custom genomes (handles file:// vs HTTP)
- `populateGenomeDropdown()`: Appends custom genomes from `CUSTOM_GENOMES` to the genome dropdown
- `parseReferenceFiles()`: Extracts FASTA/FAI/GTF from a list of files

## Session Config Format

Sessions are stored as `config.json` with this structure:
```json
{
  "genome": "hg38",
  "region": "chr17:7,661,779-7,687,550",
  "tracks": [{"name": "...", "file": "sample.bw", "color": "#FF0000", "type": "wig", "format": "bigwig"}]
}
```

## Supported Genomes

**Preset:** hg38, hg19, mm10, mm39 - gene annotations auto-load from UCSC/Ensembl.

**Custom:** Any genome via `references/<name>/` subdirectories containing FASTA + optional FAI/GTF/GFF files. Custom genomes use `custom:<id>` prefix in sessionData.genome and config.json. Run `references/update_manifest.sh` after adding new reference directories to regenerate `references/manifest.js`.

## Custom Genome Architecture

- `references/manifest.js`: Declares `var CUSTOM_GENOMES = {...}` global, loaded via `<script>` tag (works on both file:// and HTTP)
- A default empty `CUSTOM_GENOMES = {}` is declared before the manifest script, so missing manifest causes no errors
- On HTTP: FASTA/GTF files loaded via relative paths from manifest
- On file://: User must provide FASTA/GTF files via file picker or drag-drop
- `references/update_manifest.sh`: Scans subdirectories and regenerates manifest.js

## Development Notes

- No tests, linting, or build commands - edit the HTML file directly
- To test: Open `genome-browser-share.html` in a browser
- For custom genome testing via HTTP: `python -m http.server` in project root
- IGV trackViews array includes ruler/gene tracks before data tracks; track matching uses name lookup
