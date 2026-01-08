# 📡 Stream Monitoring Sandbox

This project is a sandbox for monitoring video stream quality using ffmpeg and ffprobe.
Run one command and get codec, resolution, bitrate, FPS, black frames, and freezes.

Example:
```
./monitor.sh https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```




It analyzes a live or VOD stream (HLS, file, HTTP, etc.) and generates a simple quality report including bitrate, FPS, black frames, and freezes.  
The goal is to quickly validate stream health and experiment with video quality monitoring techniques.

---

## ✨ Features

- Stream metadata extraction (codec, resolution)
- Bitrate and FPS monitoring
- Black frame detection with time intervals
- Freeze detection
- Interactive runner for test streams
- Automatic cleanup of temporary logs

---

## 🛠️ Requirements

- Bash
- ffmpeg (with `blackdetect` and `freezeDetect`)
- ffprobe

### Install ffmpeg

macOS:
```bash
brew install ffmpeg
```
Ubuntu / Debian:
```
sudo apt install ffmpeg
```

---

## 📂 Project Structure

├── monitor.sh # Core stream monitoring script
├── Run.sh # Interactive runner
└── black_frame/
└── hls_black_test/
└── index.m3u8 # Test stream with black frames


---

## 🚀 How It Works

The monitoring process runs in three passes:

1. Bitrate and FPS analysis  
   Parses ffmpeg stats output.

2. Black frame detection  
   Uses the blackdetect video filter.

3. Freeze detection  
   Uses the freezeDetect video filter.

All results are parsed from temporary logs and summarized into a readable report.

---

## ▶️ Usage

### Interactive mode

````
chmod +x monitor.sh Run.sh
./Run.sh
````


Choose between:
- A normal HLS test stream
- A local stream containing black frames

---

### Direct mode

```
./monitor.sh <stream_url>
```

Examples:

```bash
./monitor.sh https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```
```bash
./monitor.sh file:///absolute/path/to/stream.m3u8`
```


---

## 📊 Example Output

================= STREAM REPORT =================
Codec : h264
Resolution : 1280x720
Bitrate : 2150 kbps
FPS : 25
Black frames : 2
Freezes : 1

Black frame intervals (seconds):
• From 12.34 → 14.02 (duration: 1.68 s)

---

## ⚠️ Notes

- This is a sandbox / POC, not production-ready monitoring
- Metrics are best-effort and based on ffmpeg logs
- Long or live streams will run until manually stopped
- Detection sensitivity depends on stream content

---

## 🧪 Future Improvements

- JSON output
- Real-time monitoring loop
- Threshold-based alerts
- Metrics export (Datadog / Prometheus)
- Rust or Go implementation

---

## 📄 License

MIT
