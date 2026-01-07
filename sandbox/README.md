📡 Stream Monitoring Sandbox

This project is a sandbox for monitoring video stream quality using ffmpeg and ffprobe.

It analyzes a live or VOD stream (HLS, file, HTTP, etc.) and produces a simple quality report including:

Codec & resolution

Average bitrate

FPS

Black frame detection

Freeze detection

The goal is to quickly validate stream health and experiment with video quality monitoring techniques.

✨ Features

📊 Stream metadata extraction (codec, resolution)

📈 Bitrate & FPS monitoring

🖤 Black frame detection (with time intervals)

❄️ Freeze detection

🧪 Interactive runner for test streams

🧹 Automatic cleanup of temporary logs

🛠️ Requirements

Make sure the following tools are installed:

bash

ffmpeg (with blackdetect and freezeDetect filters)

ffprobe

On macOS (Homebrew):

brew install ffmpeg


On Ubuntu:

sudo apt install ffmpeg

📂 Project Structure
.
├── monitor.sh      # Core stream monitoring script
├── Run.sh          # Interactive runner
└── black_frame/
    └── hls_black_test/
        └── index.m3u8   # Test stream with black frames

🚀 How It Works
monitor.sh

The main script performs three analysis passes on the stream:

Bitrate & FPS

Uses ffmpeg stats output

Black frame detection

Uses blackdetect filter

Freeze detection

Uses freezeDetect filter

Temporary logs are parsed and summarized into a readable report.

Example Output
================= STREAM REPORT =================
Codec           : h264
Resolution      : 1280x720
Bitrate         : 2150 kbps
FPS             : 25
Black frames    : 2
Freezes         : 1

Black frame intervals (seconds):
  • From 12.34 → 14.02 (duration: 1.68 s)
=================================================
🎉 Monitoring completed.

▶️ Usage
Option 1 — Run interactively
chmod +x Run.sh monitor.sh
./Run.sh


You’ll be prompted to choose:

1) Normal stream
2) Stream with black frames

Option 2 — Run directly on any stream
./monitor.sh <stream_url>


Examples:

./monitor.sh https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8

./monitor.sh file:///path/to/your/stream.m3u8

⚠️ Notes & Limitations

This is a sandbox / POC, not a production monitoring system

Metrics are derived from ffmpeg logs (best-effort)

Long live streams will run until manually stopped

Freeze detection sensitivity may vary depending on content

🧪 Ideas for Next Steps

Export metrics to JSON

Push results to Datadog / Prometheus

Real-time monitoring loop

Threshold-based alerts

Rewrite core logic in Rust or Go

Support multiple renditions (ABR)

📄 License

MIT — feel free to experiment, fork, and improve.