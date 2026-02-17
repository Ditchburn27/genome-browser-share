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
- `sessionData` object: Stores genome, locus, tracks array, and bigWigFiles map
- `igvBrowser`: IGV.js browser instance created via `igv.createBrowser()`
- File handling: Uses File API with drag-drop and webkitdirectory for folder uploads
- Track management: Syncs between sessionData.tracks and igvBrowser.trackViews

**Two-view UI pattern:**
- Setup view (`#setupView`): File upload and session configuration
- Browser view (`#browserView`): IGV visualization with controls

## Key Functions

- `processFiles()`: Parses config.json and BigWig files, populates sessionData
- `launchBrowser()`: Creates IGV browser instance with track configuration
- `updateTrackColor()/updateTrackName()`: Syncs UI changes to IGV trackViews by name matching
- `saveSessionConfig()`: Exports current state as config.json

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

hg38, hg19, mm10, mm39 - gene annotations auto-load from UCSC/Ensembl.

## Development Notes

- No tests, linting, or build commands - edit the HTML file directly
- To test: Open `genome-browser-share.html` in a browser
- IGV trackViews array includes ruler/gene tracks before data tracks; track matching uses name lookup
