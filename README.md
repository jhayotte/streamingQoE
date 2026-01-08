# Video Quality of Experience (QoE) Monitoring

This repository contains **two complementary projects** exploring how to measure **video Quality of Experience (QoE)** using FFmpeg:

1. A **bash-based sandbox** for fast experimentation and validation  
2. A **Rust-based monitor** designed for production-grade metrics and observability

Together, they provide a path from **experimentation → reliable metrics → future production integration**.

---

## TL;DR

- `sandbox/` → quick FFmpeg experiments (FPS, bitrate, black frames, freezes)
- `video-qoe-monitor/` → Rust implementation emitting Datadog-ready metrics
- Supports **remote HLS streams** and **local test videos**
- Black frame and freeze detection included
- Designed as a foundation for real-time video QoE monitoring

---

## Repository Overview

```
├─ sandbox/ # FFmpeg-based experimentation
│ ├─ monitor.sh
│ ├─ Run.sh
│ └─ black_frame/ # Local HLS video with black frames
│
├─ video-qoe-monitor/ # Rust-based QoE monitor
│ └─ src/main.rs
│
└─ README.md
```


---

## Project 1: Sandbox (FFmpeg Experiments)

### Purpose

The sandbox exists to:

- Validate **FFmpeg filters and flags**
- Understand what metrics can realistically be extracted
- Test **black frame** and **freeze detection**
- Experiment quickly without compilation or dependencies

### Key Capabilities

- Measure:
  - FPS
  - Bitrate
  - Resolution & codec
- Detect:
  - Black frames
  - Video freezes
- Works with:
  - Public HLS streams
  - Local HLS playlists (`file://...`)

This sandbox is intentionally **simple and disposable** — its role is to prove *what is possible* before implementing it in Rust.

---

## Project 2: Rust Video QoE Monitor

### Purpose

The Rust project is the **production-oriented evolution** of the sandbox.

It aims to:

- Run FFmpeg as a subprocess
- Parse its live output
- Extract QoE signals in real time
- Emit **structured metrics** suitable for observability platforms

### Current Capabilities

- Monitor any video stream (HLS or local)
- Extract:
  - FPS
  - Bitrate
  - Black frame count
  - Freeze count
- Output metrics in **Datadog / DogStatsD format**
- Tag metrics with:
  - `service`
  - `env`

### Example Metrics

```
video.qoe.fps:24.00|g#env:prod,service:player-web
video.qoe.bitrate_kbps:2150|g#env:prod,service:player-web
video.qoe.black_frames:1|c#env:prod,service:player-web
video.qoe.freezes:0|c#env:prod,service:player-web
```


---

## How the Two Projects Fit Together

| Sandbox | Rust Monitor |
|-------|-------------|
| Fast iteration | Production-oriented |
| Manual inspection | Structured metrics |
| Ad-hoc scripts | Typed, testable code |
| FFmpeg exploration | Observability integration |

The sandbox answers:  
> *“Can FFmpeg detect this signal?”*

The Rust project answers:  
> *“How do we turn this into reliable metrics?”*

---

## Why This Exists

Video QoE issues (black screens, freezes, low FPS) are often **invisible to traditional monitoring**.

This repository explores how to:
- Detect real playback issues
- Quantify user impact
- Feed observability platforms with meaningful QoE signals

It is intentionally **tooling-first**, not player-specific.

---

## Future Direction

- Native DogStatsD UDP emission
- Time-windowed aggregation
- Adaptive bitrate awareness
- Alerting use-cases (black screen > X seconds)
- Integration with real production streams

---

## Status

🧪 Experimental / Exploratory  
⚙️ Actively evolving  
🧠 Focused on learning and correctness

---

