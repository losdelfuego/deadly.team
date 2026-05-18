#!/usr/bin/env bash
# publish_episode.sh — Rename audio, update RSS, git push
# Usage: publish_episode.sh <epNumber> "Episode Title" <path/to/audio.m4a>
# Example: publish_episode.sh 25 "Neon Dragons" ~/Downloads/audio_overview.m4a

set -euo pipefail

PODCAST_DIR="$HOME/devel/GitHub/deadly.team/podcast"
FILES_DIR="$PODCAST_DIR/files"
RSS_FILE="$PODCAST_DIR/feed.rss"
BASE_URL="https://deadly.team/podcast/files"

if [[ $# -lt 3 ]]; then
  echo "Usage: publish_episode.sh <epNumber> \"Episode Title\" <path/to/audio.m4a>" >&2
  exit 1
fi

EP_NUM="$1"
TITLE="$2"
SOURCE_AUDIO="$3"

if [[ ! -f "$SOURCE_AUDIO" ]]; then
  echo "❌ Audio file not found: $SOURCE_AUDIO" >&2
  exit 1
fi

if [[ ! -f "$RSS_FILE" ]]; then
  echo "❌ RSS file not found: $RSS_FILE" >&2
  exit 1
fi

# Build filename: ep25_NeonDragons.m4a
SAFE_TITLE="${TITLE// /}"
SAFE_TITLE="${SAFE_TITLE//[^a-zA-Z0-9_\-]/}"
FILENAME="ep${EP_NUM}_${SAFE_TITLE}.m4a"
DEST_AUDIO="$FILES_DIR/$FILENAME"

# Move and rename audio
echo "Moving audio to: $DEST_AUDIO"
mv "$SOURCE_AUDIO" "$DEST_AUDIO"

# Get file size
FILE_SIZE=$(stat -f %z "$DEST_AUDIO")

# Build pubDate
PUB_DATE=$(date -u "+%a, %d %B %Y %H:%M:%S GMT")

# Write new item to a temp file to avoid awk variable escaping issues
ITEM_TMP=$(mktemp)
cat > "$ITEM_TMP" << ITEM
    <item>
      <title>${TITLE}</title>
      <guid>ep${EP_NUM}</guid>
      <pubDate>${PUB_DATE}</pubDate>
      <enclosure url="${BASE_URL}/${FILENAME}"
                 length="${FILE_SIZE}"
                 type="audio/m4a"/>
    </item>
ITEM

# Insert new item before the first existing <item>
if grep -q '<item>' "$RSS_FILE"; then
  awk -v item_file="$ITEM_TMP" '
    !inserted && /<item>/ {
      while ((getline line < item_file) > 0) print line
      inserted=1
    }
    { print }
  ' "$RSS_FILE" > "${RSS_FILE}.tmp" && mv "${RSS_FILE}.tmp" "$RSS_FILE"
  rm -f "$ITEM_TMP"
else
  rm -f "$ITEM_TMP"
  echo "❌ Could not find an existing <item> in feed.rss to insert before." >&2
  echo "   Please add the first entry manually." >&2
  exit 1
fi

echo ""
echo "✅ RSS updated: $RSS_FILE"
echo "   Episode:  ep${EP_NUM} — $TITLE"
echo "   File:     $FILENAME ($FILE_SIZE bytes)"
echo "   PubDate:  $PUB_DATE"
echo ""

# Git
cd "$HOME/devel/GitHub/deadly.team"
git add "podcast/files/$FILENAME" "podcast/feed.rss"
git commit -m "ep${EP_NUM}: ${TITLE}"
git push

echo ""
echo "🎙️  Episode ep${EP_NUM} is live!"
