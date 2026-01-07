#!/usr/bin/env bash

# =========================================
# Script : generate_hls_blackframe_test.sh
# Objectif : créer un flux HLS <20Mo contenant des blackframes
# =========================================

STREAM_URL=${1:-"https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"}

RESOLUTION="640x360"
VIDEO_BITRATE="400k"
AUDIO_BITRATE="48k"
BLACK_DURATION=3
OUTPUT_DIR="hls_black_test"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Téléchargement d'une courte portion du flux original..."
ffmpeg -y -i "$STREAM_URL" -t 10 \
  -vf "scale=$RESOLUTION" \
  -c:v libx264 -b:v $VIDEO_BITRATE \
  -c:a aac -b:a $AUDIO_BITRATE \
  input_clip.mp4

echo "Génération du segment noir (${BLACK_DURATION}s)..."
ffmpeg -y -f lavfi -i color=c=black:s=$RESOLUTION:r=30:d=$BLACK_DURATION \
    -pix_fmt yuvj420p -color_range pc \
    -c:v libx264 -crf 0 \
    black.mp4
  # -f lavfi -i anullsrc=r=48000:cl=stereo \
  # -c:v libx264 -b:v $VIDEO_BITRATE \
  # -c:a aac -b:a $AUDIO_BITRATE \
  # -shortest black.mp4

echo "Concaténation des clips (clip -> noir -> clip)..."
printf "file 'input_clip.mp4'\nfile 'black.mp4'\nfile 'input_clip.mp4'\n" > list.txt
ffmpeg -y -f concat -safe 0 -i list.txt -c copy merged.mp4

echo "Génération du flux HLS..."
ffmpeg -y -i merged.mp4 \
  -c:v libx264 -b:v $VIDEO_BITRATE \
  -c:a aac -b:a $AUDIO_BITRATE \
  -hls_time 2 \
  -hls_playlist_type vod \
  -hls_segment_filename "${OUTPUT_DIR}/segment_%03d.ts" \
  "${OUTPUT_DIR}/index.m3u8"

echo "Flux HLS généré dans : $OUTPUT_DIR/"
echo "Fichier playlist : $OUTPUT_DIR/index.m3u8"
echo "Taille totale : $(du -h $OUTPUT_DIR | cut -f1)"

echo "Vous pouvez maintenant tester votre monitoring sur : file://$(pwd)/$OUTPUT_DIR/index.m3u8"
