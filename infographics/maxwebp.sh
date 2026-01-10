#!/bin/bash

# Configuration
SIZE_THRESHOLD=1048576  # 1 MB in bytes
LOSSLESS=0

# ----------------------------------------------------
# Helper: Get File Size
# ----------------------------------------------------
get_file_size() {
    wc -c < "$1" | tr -d ' '
}

# ----------------------------------------------------
# Core Processing Function
# ----------------------------------------------------
process_image() {
    local input_file="$1"
    
    # 1. Validation
    if [ ! -e "$input_file" ]; then return; fi
    
    local ext="${input_file##*.}"
    local ext_lower="${ext,,}" # Lowercase
    # Get just the filename without path for cleaner output/renaming
    local base_name=$(basename "${input_file%.*}")
    local dir_name=$(dirname "$input_file")
    
    # 2. Filter Criteria
    if [[ "$ext_lower" == "webp" ]]; then
        local current_size=$(get_file_size "$input_file")
        if (( current_size <= SIZE_THRESHOLD )); then
            echo "⏭️  Skipping $input_file (Size is $(($current_size/1024))KB, under limit)"
            return
        fi
    elif [[ "$ext_lower" != "png" ]]; then
        return
    fi

    echo "------------------------------------------------"
    echo "Processing: $input_file"

    # Define paths
    local temp_output="${dir_name}/${base_name}.tmp.webp"
    local final_output="${dir_name}/${base_name}.webp"

    # 3. Compression
    # -lossless -z 9 -m 6 -mt -progress -metadata all
    if [ $LOSSLESS -eq 1]; then
        cwebp -lossless -z 9 -m 6 -mt -progress -metadata all -q 100 "$input_file" -o "$temp_output"
    else
        cwebp -q 90 -m 6 -mt -progress -metadata all "$input_file" -o "$temp_output"
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Error: Compression failed."
        [ -f "$temp_output" ] && rm "$temp_output"
        return
    fi

    # 4. Compare Sizes
    local size_orig=$(get_file_size "$input_file")
    local size_new=$(get_file_size "$temp_output")

    echo "   Original Size: $size_orig bytes"
    echo "   New Size:      $size_new bytes"

    if (( size_new < size_orig )); then
        echo "✅ Success: New image is smaller."

        # Rename Original -> Original-TooLarge.ext
        local too_large_name="${dir_name}/${base_name}-TooLarge.${ext}"
        
        mv "$input_file" "$too_large_name"
        echo "   Renamed original to: $(basename "$too_large_name")"

        # Rename New -> Final
        mv "$temp_output" "$final_output"
        echo "   Saved new image as:  $(basename "$final_output")"
        
        # Mark processed to avoid loops in batch mode
        # We use the full path relative to where we started to be safe
        processed_files["$final_output"]=1

    else
        echo "⚠️  Result not smaller. Discarding new image."
        rm "$temp_output"
    fi
}

# ----------------------------------------------------
# Batch Logic Function
# ----------------------------------------------------
run_batch_mode() {
    echo "🔹 Starting batch processing in: $(pwd)"
    
    shopt -s nullglob # Handle empty directories gracefully
    
    # 1. Process all PNGs first
    for f in *.png; do
        process_image "$f"
    done

    # 2. Process WebPs
    for f in *.webp; do
        # Check if we just generated this file from a PNG
        # We reconstruct the path `./filename` to match how the loop sees it
        if [[ ${processed_files["./$f"]} || ${processed_files["$f"]} ]]; then
            continue
        fi
        
        # Skip backup files
        if [[ "$f" == *"-TooLarge.webp" ]]; then
            continue
        fi

        process_image "$f"
    done
}

# ----------------------------------------------------
# Main Execution Flow
# ----------------------------------------------------

# Track processed files to prevent double-processing
declare -A processed_files

target="$1"

if [ -n "$target" ] && [ -f "$target" ]; then
    # --- Mode: Single File ---
    echo "🔹 Mode: Single File"
    process_image "$target"

elif [ -n "$target" ] && [ -d "$target" ]; then
    # --- Mode: Specific Directory ---
    echo "🔹 Mode: Specific Directory"
    # Change into that directory so the batch logic works simply
    cd "$target" || exit 1
    run_batch_mode

else
    # --- Mode: Current Directory (Default) ---
    echo "🔹 Mode: Current Directory (No arguments provided)"
    run_batch_mode
fi

echo "------------------------------------------------"
echo "Processing complete."