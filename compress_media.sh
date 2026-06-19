#!/bin/bash

export SRC_DIR="/directory/where/files/are"
export DST_DIR="/directory/where/files/will/go/to"

mkdir -p "$DST_DIR"
cd "$SRC_DIR" || exit 1

find . -type d -print0 | parallel -0 mkdir -p "$DST_DIR/{}"

process_image() {
    local img="$1"
    local base="${img%.*}"
    local dest="$DST_DIR/${base}.webp"
    if [ ! -f "$dest" ]; then
        magick "$img" -quality 80 "$dest"
    fi
}
export -f process_image

process_video() {
    local vid="$1"
    local base="${vid%.*}"
    local dest="$DST_DIR/${base}.mp4"
    if [ ! -f "$dest" ]; then
        ffmpeg -i "$vid" -c:v hevc_nvenc -pix_fmt yuv420p -preset p6 -cq 28 -c:a aac -b:a 128k "$dest" -y -loglevel error
    fi
}
export -f process_video

process_other() {
    local file="$1"
    local dest="$DST_DIR/$file"
    if [ ! -f "$dest" ]; then
        cp -n "$file" "$dest"
    fi
}
export -f process_other

find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tif" \) -print0 | parallel -0 -j 12 process_image {}

find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.asf" -o -iname "*.3gp" \) -print0 | parallel -0 -j 2 process_video {}

find . -type f ! \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.asf" -o -iname "*.3gp" \) -print0 | parallel -0 -j 12 process_other {}
