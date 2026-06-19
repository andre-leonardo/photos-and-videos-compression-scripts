# 🚀 Extreme Media Compressor

A set of highly optimized, parallelized, and hardware-accelerated Bash scripts to drastically reduce the size of personal photo and video backups without noticeable quality loss.

Designed to extract **100% performance** out of modern hardware by combining multi-threaded CPU processing for images and NVIDIA GPU hardware acceleration (NVENC) for videos.

## 📦 Features

- **Blazing Fast Video Encoding:** Uses NVIDIA's NVENC (`hevc_nvenc` or `av1_nvenc`) to compress videos dozens of times faster than CPU encoding.
- **Max CPU Utilization:** Uses `GNU Parallel` to process multiple images simultaneously using all available CPU threads.
- **Smart Formatting:** Converts bulky images (`.jpg`, `.png`, `.bmp`) to Google's highly efficient `.webp` format.
- **Directory Mirroring:** Recreates the exact same folder structure from the source to the destination, automatically copying non-media files (like documents or PDFs) so your backup stays organized.
- **CPU Fallback:** Automatically detects if a video is incompatible with the GPU (e.g., unsupported dimensions) and seamlessly falls back to CPU encoding (`libx265`).

## 🛠️ Requirements

To run these scripts, you need a Linux environment with the following packages installed:
- `ffmpeg` (compiled with NVENC support)
- `imagemagick` (for `magick`)
- `parallel` (GNU Parallel)
- An NVIDIA GPU (RTX series recommended for AV1 support)

*On Arch Linux / CachyOS:*
```bash
sudo pacman -S ffmpeg imagemagick parallel
```

## 📜 Scripts Overview

### 1. `compress_media.sh`
The primary script. It mirrors the source directory to a new compressed directory.
- Converts images to `.webp` (Quality 80) via CPU.
- Converts videos to `.mp4` (H.265 / HEVC via GPU NVENC).
- Copies all other remaining files intact.

**Usage:**
Edit the `SRC_DIR` and `DST_DIR` variables inside the script to point to your folders, then run:
```bash
chmod +x compress_media.sh
./compress_media.sh
```

### 2. `compress_videos_av1.sh`
The extreme compression script. It scans an already populated directory and re-encodes all videos using the **AV1** codec (`av1_nvenc`) with a higher Constant Quantization (CQ 35) for maximum space saving. Overwrites the files in-place.
- Uses `av1_nvenc` via GPU.
- If the GPU rejects the video (e.g., extremely low resolutions like old 3GP files), it falls back to CPU encoding (`libx265`).

**Usage:**
Edit the `DST_DIR` variable to point to your target folder, then run:
```bash
chmod +x compress_videos_av1.sh
./compress_videos_av1.sh
```

### 3. 'compress_media_av1.sh'
Combines both scripts above, if you want to directly compress videos in av1 format.
**Usage:**
Edit the `SRC_DIR` and `DST_DIR` variables inside the script to point to your folders, then run:
```bash
chmod +x compress_media.sh
./compress_media_av1.sh
```

## 📈 Real-World Results
In a real-world test with a massive personal backup folder spanning over a decade of photos and videos:
- **Original Size:** 6.8 GB
- **Compressed Size:** 3.0 GB
- **Space Saved:** ~55% reduction, completely preserving directory organization.

## ⚠️ Disclaimer
Always run tests on a small subset of your files to ensure the quality matches your expectations before running it on your entire backup drive.

---
*Created as part of an automated AI-assisted system optimization.*
*AI writes in a kind of cringy manner*
