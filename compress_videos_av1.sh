#!/bin/bash

export DST_DIR="/directory/where/videos/are"

process_av1() {
    local vid="$1"
    local tmp_vid="${vid}.tmp.mp4"
    
    # Using NVIDIA's AV1 (av1_nvenc).
    # CQ 35 is a more agressive compression,
    # slight quality loss.
    # audio too is slighty compressed 96k.
    if ffmpeg -i "$vid" -c:v av1_nvenc -pix_fmt yuv420p -preset p6 -cq 35 -c:a aac -b:a 96k "$tmp_vid" -y -loglevel error; then
        # overwrites original video
        mv "$tmp_vid" "${vid%.*}.mp4"
        
        # If not mp4 (lik3 .3gp), deletes the original.
        if [[ "$vid" != "${vid%.*}.mp4" ]]; then
            rm "$vid"
        fi
    else
        # Fallback: If video is too short and the GPU ignores it
        # the CPU is used.
        if ffmpeg -i "$vid" -c:v libx265 -preset veryfast -crf 35 -c:a aac -b:a 96k "$tmp_vid" -y -loglevel error; then
            mv "$tmp_vid" "${vid%.*}.mp4"
            if [[ "$vid" != "${vid%.*}.mp4" ]]; then
                rm "$vid"
            fi
        else
            # Failure from corrpted videos cleans the temporary files
            rm -f "$tmp_vid"
        fi
    fi
}
export -f process_av1

#Finds all videos in the folder and throws them to be processed
find "$DST_DIR" -type f \( -iname "*.mp4" -o -iname "*.3gp" \) -print0 | parallel -0 -j 2 process_av1 {}
