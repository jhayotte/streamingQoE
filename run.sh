#!/usr/bin/env bash

echo "STREAM MONITOR RUNNER"
echo "1) Normal stream"
echo "2) Stream with black frames"
read -rp "Choose 1 or 2: " CHOICE

STREAM_URL=""
case $CHOICE in
  1) STREAM_URL="https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" ;;
  2) STREAM_URL="file://$(pwd)/black_frame/hls_black_test/index.m3u8" ;;
  *) echo "Invalid option"; exit 1 ;;
esac

echo "Monitoring: $STREAM_URL"
./monitor.sh "$STREAM_URL"
