#!/bin/bash

export SRC_DIR="/path/to/source"
export DST_DIR="/path/to/destination"

mkdir -p "$DST_DIR"
cd "$SRC_DIR" || exit 1

echo "============================================="
echo "1. Recreating directory structure..."
echo "============================================="
find . -type d -print0 | parallel -0 mkdir -p "$DST_DIR/{}"

# ---------------------------------------------------------
# Image Processing Function (WebP)
# ---------------------------------------------------------
process_image() {
    local img="$1"
    local base="${img%.*}"
    local dest="$DST_DIR/${base}.webp"
    
    # Skip if file already exists
    if [ ! -f "$dest" ]; then
        magick "$img" -quality 80 "$dest"
    fi
}
export -f process_image

# ---------------------------------------------------------
# Video Processing Function (AV1 with CPU Fallback)
# ---------------------------------------------------------
process_video() {
    local vid="$1"
    local base="${vid%.*}"
    local dest="$DST_DIR/${base}.mp4"
    
    # Skip if file already exists
    if [ ! -f "$dest" ]; then
        # Primary Attempt: NVIDIA AV1 Hardware Encoding (av1_nvenc)
        # CQ 35 provides aggressive compression with minor quality loss
        if ffmpeg -i "$vid" -c:v av1_nvenc -pix_fmt yuv420p -preset p6 -cq 35 -c:a aac -b:a 96k "$dest" -y -loglevel error; then
            : # Success
        else
            # CPU Fallback (libx265) for files rejected by GPU (e.g. extreme low resolutions)
            if ! ffmpeg -i "$vid" -c:v libx265 -preset veryfast -crf 35 -c:a aac -b:a 96k "$dest" -y -loglevel error; then
                rm -f "$dest" # Clean up corrupted partial files
            fi
        fi
    fi
}
export -f process_video

# ---------------------------------------------------------
# Copy Remaining Files Function
# ---------------------------------------------------------
process_other() {
    local file="$1"
    local dest="$DST_DIR/$file"
    
    if [ ! -f "$dest" ]; then
        cp -n "$file" "$dest"
    fi
}
export -f process_other

echo "============================================="
echo "2. Compressing images to WebP (CPU multi-threading)..."
echo "============================================="
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tif" \) -print0 | \
    parallel -0 -j $(nproc) process_image {}

echo "============================================="
echo "3. Compressing videos to AV1 (GPU Hardware)..."
echo "============================================="
find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.asf" -o -iname "*.3gp" \) -print0 | \
    parallel -0 -j 2 process_video {}

echo "============================================="
echo "4. Copying remaining non-media files..."
echo "============================================="
find . -type f ! \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.asf" -o -iname "*.3gp" \) -print0 | \
    parallel -0 -j $(nproc) process_other {}

echo "============================================="
echo "Compression complete! Files saved to $DST_DIR"
echo "============================================="
