use std::process::{Command, Stdio};
use std::io::{BufRead, BufReader};
use regex::Regex;
use clap::Parser;
use std::time::{Instant, Duration};

#[derive(Parser, Debug)]
struct Args {
    /// Stream URL (HLS, file, HTTP…)
    #[arg(long)]
    stream_url: String,

    /// Service name (Datadog tag)
    #[arg(long, default_value = "video-player")]
    service: String,

    /// Environment (Datadog tag)
    #[arg(long, default_value = "dev")]
    env: String,
}

#[derive(Default, Debug)]
struct Metrics {
    fps: Option<f64>,
    bitrate_kbps: Option<f64>,
    black_frames: u64,
    freezes: u64,
}

fn main() {
    let args = Args::parse();
    println!("📡 Monitoring {}", args.stream_url);

    let mut child = Command::new("ffmpeg")
        .args([
            "-i", &args.stream_url,
            "-vf", "blackdetect=d=0.05:pix_th=0.10,freezedetect=n=5",
            "-an",
            "-f", "null", "-",
            "-stats",
            "-loglevel", "info",
        ])
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to start ffmpeg");

    let stderr = child.stderr.take().expect("No stderr");
    let reader = BufReader::new(stderr);

    // --- Regexes ---
    let re_fps = Regex::new(r"fps=\s*([\d.]+)").unwrap();
    let re_bitrate = Regex::new(r"bitrate=\s*([\d.]+)k?bits(?:/s)?").unwrap();
    let re_black = Regex::new(
        r"black_start:(?P<start>[\d.]+).*black_end:(?P<end>[\d.]+).*black_duration:(?P<dur>[\d.]+)"
    ).unwrap();
    let re_freeze = Regex::new(r"freeze_start\s+(?P<start>[\d.]+)").unwrap();

    let mut metrics = Metrics::default();
    let mut fps_sum = 0.0;
    let mut fps_count = 0;
    let mut bitrate_sum = 0.0;
    let mut bitrate_count = 0;

    let mut last_emit = Instant::now();
    let emit_interval = Duration::from_secs(5); // emit metrics every 5s

    for line in reader.lines().flatten() {
        // --- Parse FPS ---
        if let Some(caps) = re_fps.captures(&line) {
            if let Ok(fps_val) = caps[1].parse::<f64>() {
                fps_sum += fps_val;
                fps_count += 1;
                metrics.fps = Some(fps_sum / fps_count as f64);
            }
        }

        // --- Parse bitrate ---
        if let Some(caps) = re_bitrate.captures(&line) {
            if let Ok(br_val) = caps[1].parse::<f64>() {
                bitrate_sum += br_val;
                bitrate_count += 1;
                metrics.bitrate_kbps = Some(bitrate_sum / bitrate_count as f64);
            }
        }

        // --- Parse black frames ---
        if let Some(caps) = re_black.captures(&line) {
            metrics.black_frames += 1;
            let start: f64 = caps["start"].parse().unwrap();
            let end: f64 = caps["end"].parse().unwrap();
            let dur: f64 = caps["dur"].parse().unwrap();
            println!("🖤 Black frame detected: {:.2}s → {:.2}s (duration {:.2}s)", start, end, dur);
        }

        // --- Parse freezes ---
        if re_freeze.is_match(&line) {
            metrics.freezes += 1;
            println!("❄️ Freeze detected");
        }

        // --- Emit metrics periodically ---
        if last_emit.elapsed() >= emit_interval {
            emit_metrics(&metrics, &args);
            last_emit = Instant::now();
        }
    }

    // Emit final metrics at the end
    emit_metrics(&metrics, &args);
    let _ = child.wait();
}

fn emit_metrics(metrics: &Metrics, args: &Args) {
    let tags = format!("#env:{},service:{}", args.env, args.service);

    if let Some(fps) = metrics.fps {
        println!("video.qoe.fps:{:.2}|g{}", fps, tags);
    }

    if let Some(br) = metrics.bitrate_kbps {
        println!("video.qoe.bitrate_kbps:{:.0}|g{}", br, tags);
    }

    println!("video.qoe.black_frames:{}|c{}", metrics.black_frames, tags);
    println!("video.qoe.freezes:{}|c{}", metrics.freezes, tags);
}
