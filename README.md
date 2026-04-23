# IGV Genome Browser Web App

A lightweight, browser-based genome browser built on [IGV.js](https://github.com/igvteam/igv.js) that makes it easy to visualize and share BigWig genomics data with collaborators — and generate publication-ready multi-locus figures.

![IGV.js](https://img.shields.io/badge/IGV.js-2.15.8-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎯 Key Features

- **Easy Session Sharing**: Save and share browser sessions with config files — no path dependencies
- **Proper BigWig Support**: Native BigWig file parsing using IGV.js
- **Built-in Gene Annotations**: Automatic RefSeq gene tracks from UCSC/Ensembl
- **Desktop IGV Appearance**: Familiar interface matching the desktop IGV application
- **Customizable Tracks**: Change track names, colors, and heights on the fly
- **Drag-to-Reorder Tracks**: Rearrange track order via drag handle in the settings table, synced to the browser view
- **Autoscale Groups**: Create named groups and assign tracks via shift-click multi-select for shared Y-axis scaling
- **BED Annotation Tracks**: Load BED files (`.bed`) alongside BigWig files as annotation tracks
- **Add Tracks Mid-Session**: Upload additional BigWig or BED files into a running session without reloading
- **Multi-Locus Figure View**: Side-by-side comparison of multiple genomic regions across all tracks — export as SVG
- **Zero Installation**: Runs entirely in the browser — no backend required

## 🚀 Quick Start

### Option 1: Load Existing Session

1. Open `genome-browser-share.html` in your web browser
2. Drag and drop a folder containing:
   - `config.json` (session configuration)
   - One or more BigWig files (`.bw`, `.bigWig`) and/or BED annotation files (`.bed`)
3. The browser launches automatically with all your settings preserved

### Option 2: Create New Session

1. Open `genome-browser-share.html` in your web browser
2. Select a reference genome (hg38, hg19, mm10, mm39)
3. Upload your BigWig files
4. Click "Launch Browser"

## 📁 Session Configuration Format

The `config.json` file stores all your session settings:

```json
{
  "genome": "hg38",
  "region": "chr17:7,661,779-7,687,550",
  "autoscaleGroups": ["Group 1"],
  "tracks": [
    {
      "name": "Sample_1_H4K20me1",
      "file": "sample1.bigWig",
      "color": "#FF0000",
      "type": "wig",
      "format": "bigwig",
      "autoscaleGroup": "Group 1"
    },
    {
      "name": "Sample_2_Control",
      "file": "sample2.bigWig",
      "color": "#00AA00",
      "type": "wig",
      "format": "bigwig",
      "autoscaleGroup": null
    }
  ]
}
```

### Config Fields

- **genome**: Reference genome (hg38, hg19, mm10, mm39, or `custom:<id>` for custom genomes)
- **region**: Genomic coordinates (e.g., "chr17:7,661,779-7,687,550")
- **autoscaleGroups**: Array of named autoscale group strings
- **tracks**: Array of track configurations (order determines display order)
  - **name**: Display name for the track
  - **file**: BigWig filename (no path, just filename)
  - **color**: Hex color code for the track
  - **type**: Track type (`"wig"` for BigWig, `"annotation"` for BED)
  - **format**: File format (`"bigwig"` or `"bed"`)
  - **autoscaleGroup**: Name of the autoscale group, or `null` for independent scaling

## 🎨 Using the Browser

### Navigation Controls

- **Location Input**: Type genomic coordinates (e.g., `chr17:7,661,779-7,687,550`) and click "Go"
- **Zoom In/Out**: Zoom buttons or the zoom slider in IGV
- **Reset**: Return to the starting location
- **Pan**: Click and drag in the track view
- **Keyboard Pan**: Left/right arrow keys pan the view left or right

### Track Customization

- **Change Colors**: Click the color picker next to any track in the "Track Settings" panel
- **Rename Tracks**: Click the track name to edit it inline
- **Adjust Height**: Use the "Track Height" dropdown to make tracks more compact or taller
- **Reorder Tracks**: Drag the handle (☰) on any track row to rearrange display order — both the settings table and the IGV browser view update to match

### Adding Tracks Mid-Session

You can add more BigWig or BED files after the session is already running — no need to restart:

1. Click **"➕ Add Tracks"** in the IGV browser toolbar to pick individual files, or
2. Click **"📁 Add Folder"** to upload an entire folder

New tracks appear in the track settings sidebar immediately, are live-loaded into the IGV view, and are automatically included when you save the session config.

### Autoscale Groups

Tracks in the same autoscale group share a common Y-axis scale, making it easy to compare signal levels across samples.

1. **Select tracks**: Click checkboxes to select individual tracks, or **shift-click** to select a range
2. **Assign a group**: Use the toolbar dropdown to pick a group, then click "Set Group"
3. **Manage groups**: Add, rename, or remove groups in the "Autoscale Groups" section below the track list
4. **Independent scaling**: Set a track's group to "None (Independent)" for its own Y-axis range

### Exporting

- **Save Session Config**: Download a `config.json` with current settings
- **Export SVG**: Save the current IGV view as an SVG image

## 🔬 Multi-Locus Figure View

The **Multi-Locus Figure** tab lets you visualise multiple genomic regions side-by-side in a clean, publication-ready layout — rendered entirely on canvas with configurable styling.

### Setting Up Loci

Click **"+ Manage Loci"** in the figure toolbar to open the locus manager:

- **Add a locus manually**: enter a label (e.g. `Rbfox3`) and genomic coordinates (e.g. `chr11:117,005,327-120,396,030`), then click **Add**
- **Capture current view**: click **"🔍 Current view"** to fill the coordinate field with whatever the IGV browser is currently showing — great for quickly pinning a region you've navigated to
- **Reorder or remove**: drag loci up/down in the list or click the remove button
- Click **Apply** to update the figure

### Figure Controls

| Control | Description |
|---|---|
| **Track height** slider | Set the pixel height of each BigWig row |
| **Y-scale** dropdown | Per-cell, by row, by autoscale group, or global max |
| **Gene model** dropdown | Squished (IGV-style), Collapsed, Full transcripts, Bar only, Arrows only |
| **Y-max** checkbox | Show/hide the Y-axis maximum label on each cell |
| **Labels** checkbox | Show/hide the track name column on the left |
| **Cell borders** checkbox | Toggle borders around each cell |
| **Figure Style** | Customise fonts, colors, and gene annotation appearance |
| **Export SVG** | Download the entire figure as a vector SVG |

### Gene Model Row

A gene annotation row appears beneath all tracks, drawn from the same GTF/GFF data used for the reference genome. In **Squished** mode, genes are packed into rows using a bump-chart layout so overlapping genes don't collide. All locus columns share the same row height so the figure stays properly aligned even when loci differ in gene density.

### Y-Scale Modes

- **Per cell** (default): each cell autoscales independently
- **By row**: all loci for a given track share the same max
- **By autoscale group**: tracks in the same autoscale group share a max across all loci
- **Global**: one max across every track and locus

## 📤 Sharing Sessions with Collaborators

### Step 1: Create Your Session
1. Load your BigWig files
2. Customise track names and colors
3. Navigate to your region of interest
4. Click "💾 Save Session Config"

### Step 2: Package for Sharing
Create a folder with:
```
session_folder/
├── config.json          (downloaded from browser)
├── sample1.bigWig       (your data file)
├── sample2.bigWig       (your data file)
└── sample3.bigWig       (your data file)
```

### Step 3: Share
- Zip the folder and send via email/cloud storage
- Share on a network drive
- Commit to a Git repository (if files aren't too large)

### Step 4: Collaborators Load Session
Recipients simply:
1. Open `genome-browser-share.html`
2. Drag and drop the entire folder
3. Browser loads with your exact configuration!

**Why this works**: The config file references filenames only (not full paths), so it works on any computer as long as the BigWig files are in the same folder as the config.

## 🔧 Supported Genomes

### Built-in Genomes

- **hg38** (GRCh38): Human genome, December 2013
- **hg19** (GRCh37): Human genome, February 2009
- **mm10** (GRCm38): Mouse genome, December 2011
- **mm39** (GRCm39): Mouse genome, June 2020

Gene annotations are automatically loaded from UCSC/Ensembl for each genome.

In addition to these four presets, you can add your own custom genome references for any organism or assembly.

## 🧬 Custom Genome References

You can use any genome assembly by providing your own FASTA reference files. Custom genomes appear in the genome dropdown alongside the built-in presets.

### Directory Structure

Place each custom genome in its own subdirectory under `references/`:

```
references/
├── manifest.js              (auto-generated, do not edit manually)
├── update_manifest.sh       (script to regenerate manifest.js)
├── sacCer3/
│   ├── sacCer3.fa           (FASTA reference - required)
│   ├── sacCer3.fa.fai       (FASTA index - recommended)
│   └── sacCer3.gtf          (gene annotations - optional)
└── dm6/
    ├── dm6.fasta            (FASTA reference - required)
    ├── dm6.fasta.fai        (FASTA index - recommended)
    └── dm6.gff3             (gene annotations - optional)
```

Each subdirectory needs:
- **FASTA file** (`.fa`, `.fasta`, `.fna`) — **required**. The genome sequence.
- **FASTA index** (`.fai`) — recommended for large genomes. Generate with `samtools faidx your_genome.fa`.
- **GTF/GFF annotation file** (`.gtf`, `.gff`, `.gff3`) — optional. Provides gene annotations in the browser and figure views.

### Generating the Manifest

After adding or removing reference directories, run:

```bash
./references/update_manifest.sh
```

This scans the subdirectories under `references/`, detects the FASTA, index, and annotation files in each one, and updates `references/manifest.js`. The manifest is what populates the genome dropdown in the UI, so you must re-run this script whenever you change the contents of `references/`.

Additional notes:
- The manifest must be regenerated whenever you add or remove reference directories — changes are not picked up automatically
- Compressed files are supported: `.fa.gz`, `.fasta.gz`, `.gtf.gz`, `.gff.gz` (with a corresponding `.fai` or `.gzi` index)
- If a subdirectory has no FASTA file, it is skipped with a warning and will not appear in the dropdown

### Using Custom Genomes

**Create New Session:**
1. Open `genome-browser-share.html`
2. Select your custom genome from the dropdown
3. Upload your BigWig or other track files
4. Click "Launch Browser"

**Load Existing Session:**
1. Drag and drop a folder containing:
   - `config.json` (with the custom genome name in the `"genome"` field)
   - Your track files (BigWig, BED, etc.)
   - The reference files (FASTA, FAI, GTF/GFF) for the custom genome
2. The browser detects the reference files and loads them automatically

### Sharing Sessions with Custom Genomes

**Option A — Include reference files in the folder (works everywhere):**

Put `config.json`, all track files, and the reference files (FASTA, FAI, GTF/GFF) together in one folder. The recipient drag-drops the entire folder and it works on both file:// and HTTP — no prior setup needed.

**Option B — Manifest-based sharing (no reference files needed):**

If the recipient already has the same genome registered in their `references/` directory and has run `./references/update_manifest.sh`, you only need to share `config.json` and the track files. They must serve the app via HTTP (`python -m http.server 8000`) rather than opening it as a file:// URL.

### HTTP Server vs File Protocol

**HTTP server (recommended for custom genomes):**

```bash
python -m http.server 8000
```

Then open `http://localhost:8000/genome-browser-share.html`. On HTTP, any genome registered in `references/manifest.js` loads automatically.

**File protocol (opening the HTML file directly):**

When opened as a `file://` URL, the browser blocks access to other local files. Either include reference files in the drag-dropped folder (Option A above), or a file picker will appear automatically so you can select them manually.

## 💡 Tips & Best Practices

### File Organization
- Keep BigWig files and config.json in the same folder
- Use descriptive filenames that make sense to others
- Consider file sizes — very large BigWigs may be slow to load

### Track Naming
- Use clear, descriptive track names (e.g., "Sample1_H3K4me3_Rep1")
- Include relevant metadata in names (condition, replicate, etc.)
- Keep names concise for readability in the figure view

### Multi-Locus Figures
- Use "By autoscale group" Y-scale to compare samples fairly across genes
- The "Current view" button in Manage Loci makes it easy to capture a region after navigating to it in the IGV tab
- Export SVG produces a vector file suitable for direct import into Illustrator or Inkscape

### Performance
- Smaller genomic regions render faster in the multi-locus view
- Fewer simultaneous tracks = better performance
- Consider using the compact track height for many-track figures

## 🐛 Troubleshooting

### BigWig files not loading
- Ensure files have `.bw`, `.bigwig`, or `.bigWig` extension
- Check that files aren't corrupted
- Try loading files one at a time to identify problematic files

### Tracks showing "No data in region"
- Verify the genomic region has coverage in your BigWig file
- Check that the correct genome assembly is selected
- Try navigating to a different region

### Config not loading properly
- Verify `config.json` is valid JSON (use a JSON validator)
- Ensure all BigWig filenames in config match actual files
- Check that file/track names don't have special characters

### Multi-locus figure shows no data
- Make sure the BigWig files are still loaded in the IGV browser tab (they must remain open in the browser)
- Check that each locus coordinate is valid for the current genome
- If gene annotations are missing, verify the genome has a GTF/GFF registered in `references/manifest.js`

## 🔬 Technical Details

### Built With
- [IGV.js](https://github.com/igvteam/igv.js) v2.15.8 — the core visualization library
- Pure HTML/CSS/JavaScript — no build process required
- Browser-native File API for local file handling
- HTML5 Canvas for multi-locus figure rendering

### Browser Requirements
- Modern web browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- File API support (all modern browsers)

### How It Works
1. BigWig files are read directly in the browser using IGV.js
2. Files are converted to blob URLs for IGV to access
3. Gene annotations are fetched from public UCSC/Ensembl servers
4. The multi-locus figure view reads BigWig data independently from IGV, using the same blob URLs
5. All processing happens client-side — no data is uploaded

### Privacy & Security
- **All data stays local** — nothing is uploaded to any server
- BigWig files are processed entirely in your browser
- Only gene annotations are fetched from public databases
- Safe to use with sensitive/unpublished data

## 📝 License

MIT License — feel free to use and modify for your research.

## 🤝 Contributing

Contributions are welcome! Some ideas for improvements:
- Additional genome assemblies
- BAM/CRAM file support
- Session state URL encoding
- Ability to hide/show tracks without removing them from the session

## 🙏 Acknowledgments

- Built on [IGV.js](https://github.com/igvteam/igv.js) by the Broad Institute
- Gene annotations from [UCSC Genome Browser](https://genome.ucsc.edu/) and [Ensembl](https://www.ensembl.org/)
- Inspired by the desktop [Integrative Genomics Viewer (IGV)](https://software.broadinstitute.org/software/igv/)

## 📧 Support

For issues or questions:
- Check the Troubleshooting section above
- Review [IGV.js documentation](https://github.com/igvteam/igv.js/wiki)
- Open an issue on GitHub

---

**Happy browsing! 🧬**
