#!/usr/bin/env bash
set -euo pipefail

# Resolve project root from script location (.claude/hooks/ → project root)
REPO="$(cd "$(dirname "$0")/../.." && pwd)"

# ── 1. Detect changes to site/index.html ─────────────────────────────────────
DIFF=$(git -C "$REPO" diff HEAD -- site/index.html 2>/dev/null || true)

# Fallback: if changes were committed this turn, check the latest commit
if [[ -z "$DIFF" ]]; then
  DIFF=$(git -C "$REPO" diff HEAD~1 HEAD -- site/index.html 2>/dev/null | head -400 || true)
fi

# Nothing changed — exit cleanly
[[ -z "$DIFF" ]] && exit 0

# Cap diff size to keep prompt manageable
DIFF=$(echo "$DIFF" | head -400)

# ── 2. Build prompt ───────────────────────────────────────────────────────────
DOC_INDEX="docs/session-state.md        — sessionData, mlState, object URL tracking
docs/setup-and-file-handling.md — processFiles(), CSV import, addTracksFromFiles()
docs/genome-reference.md        — custom genome support, manifest.js
docs/igv-integration.md         — launchBrowser(), buildIgvTrackConfig(), keyboard nav
docs/track-management-igv.md    — track controls UI, autoscale groups, Y-range
docs/multilocus-state.md        — mlState, tag system, save/load ML config
docs/multilocus-rendering.md    — mlRender() pipeline, Y-scale modes, SVG export
docs/bigwig-reader.md           — custom BigWig parser
docs/gene-annotation.md         — mlFetchGeneFeatures(), GTF/GFF parser, gene model
docs/multilocus-ui.md           — sidebar, locus manager, colour picker, tag UI
docs/utilities.md               — escHtml(), hslToHex(), parseLocusString()"

PROMPT="site/index.html was just edited. Review the diff and update any documentation files in ${REPO}/docs/ that are now stale.

Documentation files and what they cover:
${DOC_INDEX}

Git diff of site/index.html:
\`\`\`diff
${DIFF}
\`\`\`

Rules:
- Read each potentially-affected doc before editing it
- Edit only docs/*.md files — never touch site/index.html
- Update only docs whose described functions/components appear in the diff; skip unaffected ones
- Prefer targeted additions and edits over full-section rewrites
- If only CSS or HTML layout changed with no logic impact, do nothing"

# ── 3. Run claude non-interactively to update docs ────────────────────────────
cd "$REPO"
claude --dangerously-skip-permissions -p "$PROMPT" \
  --allowedTools "Edit,Read" \
  > /tmp/genome-browser-docs-update.log 2>&1 || true

exit 0
