#!/usr/bin/env bash

STREAM_URL=$1
if [ -z "$STREAM_URL" ]; then
  echo "Usage: ./monitor.sh <stream_url>"
  exit 1
fi

echo "📡 Monitoring stream: $STREAM_URL"

# --- Metadata ---
WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$STREAM_URL")
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$STREAM_URL")
CODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$STREAM_URL")

# --- Temporary logs ---
TMP_BITRATE=$(mktemp)
TMP_BLACK=$(mktemp)
TMP_FREEZE=$(mktemp)

# Pass 1 — bitrate + FPS
ffmpeg -i "$STREAM_URL" -an -f null - -loglevel info -stats 2>&1 | tee "$TMP_BITRATE" >/dev/null
# Pass 2 — black frames
ffmpeg -i "$STREAM_URL" -vf "blackdetect=d=0.05:pix_th=0.10:pic_th=0.95" -an -f null - -loglevel info 2>&1 | tee "$TMP_BLACK" >/dev/null
# Pass 3 — freezes
ffmpeg -i "$STREAM_URL" -vf "freezeDetect=n=5" -an -f null - -loglevel info 2>&1 | tee "$TMP_FREEZE" >/dev/null

# --- Parsing ---
BITRATE=$(grep -Eo "bitrate: +[0-9\.]+kbits" "$TMP_BITRATE" | sed -E 's/.* ([0-9\.]+)kbits/\1/' | tail -1)
FPS=$(grep -Eo "fps= *[0-9\.]+" "$TMP_BITRATE" | sed -E 's/fps= *//' | tail -1)
BLACK_FRAMES=$(grep -c "black_start" "$TMP_BLACK")
FREEZES=$(grep -c "freeze_start" "$TMP_FREEZE")

# --- Output ---
echo ""
echo "================= STREAM REPORT ================="
printf "%-15s : %s\n" "Codec" "$CODEC"
printf "%-15s : %sx%s\n" "Resolution" "$WIDTH" "$HEIGHT"
printf "%-15s : %s kbps\n" "Bitrate" "$BITRATE"
printf "%-15s : %s\n" "FPS" "$FPS"
printf "%-15s : %s\n" "Black frames" "$BLACK_FRAMES"
printf "%-15s : %s\n" "Freezes" "$FREEZES"

# --- Black frame intervals ---
if [ "$BLACK_FRAMES" -gt 0 ]; then
    echo ""
    echo "Black frame intervals (seconds):"
    grep "black_start" "$TMP_BLACK" | while read -r line; do
        START=$(echo "$line" | sed -n 's/.*black_start:\([0-9.]*\).*/\1/p')
        END=$(echo "$line" | sed -n 's/.*black_end:\([0-9.]*\).*/\1/p')
        DURATION=$(echo "$line" | sed -n 's/.*black_duration:\([0-9.]*\).*/\1/p')
        echo "  • From $START → $END (duration: $DURATION s)"
    done
fi

echo "================================================="
echo "🎉 Monitoring completed."

# Cleanup
rm "$TMP_BITRATE" "$TMP_BLACK" "$TMP_FREEZE"
