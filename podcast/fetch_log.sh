#!/usr/bin/env bash
# fetch_log.sh — Save an Obsidian Portal log entry as a .txt source file
# Usage: fetch_log.sh "Episode Title"
#    then paste the log text, press Enter, then Ctrl+D
# Or:   pbpaste | fetch_log.sh "Episode Title"

set -euo pipefail

DEST_DIR="$HOME/devel/GitHub/deadly.team"

if [[ $# -lt 1 ]]; then
  echo "Usage: fetch_log.sh \"Episode Title\"" >&2
  exit 1
fi

TITLE="$1"
# Sanitize title for filename: replace spaces with underscores, strip unsafe chars
SAFE_TITLE="${TITLE// /_}"
SAFE_TITLE="${SAFE_TITLE//[^a-zA-Z0-9_\-]/}"
OUTFILE="$DEST_DIR/${SAFE_TITLE}.txt"

echo "Paste the log entry text below, then press Ctrl+D when done:"
cat > "$OUTFILE"

echo ""
echo "✅ Saved to: $OUTFILE"
echo "   Title:    $TITLE"
echo ""
echo "Next steps:"
echo "  1. Upload $OUTFILE as a source in NotebookLM"
echo "  2. Enter your custom Deep Dive prompt"
echo "  3. Download the generated audio"
echo "  4. Run: publish_episode.sh <epNumber> \"$TITLE\" <path/to/downloaded.m4a>"
