import os
import shutil
import subprocess
from pathlib import Path
from PIL import Image, ImageChops, ImageFilter, ImageOps

# --- CONFIGURATION ---
SAVE_INTERMEDIATE = False  # Set to True to save debug masks and patches
# ---------------------

def get_cwebp_path():
    """Checks if cwebp is available in the system path."""
    from shutil import which
    path = which("cwebp")
    if path is None:
        print("Error: 'cwebp' tool not found. Please install libwebp and add it to your PATH.")
        exit(1)
    return path

def process_images(folder_path):
    cwebp_path = get_cwebp_path()
    folder = Path(folder_path)
    
    # Create the 'orig' subfolder if it doesn't exist
    orig_folder = folder / "orig"
    orig_folder.mkdir(exist_ok=True)

    # List all PNG files
    files = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() == '.png']

    for img_path in files:
        # Check if this is a "clean" file (skip it if so, we process based on the original)
        if img_path.name.endswith("-clean.png"):
            continue
        
        # Skip debug files if they exist from previous runs
        if img_path.name.startswith("debug_"):
            continue

        # Construct the expected clean filename
        clean_path = folder / "clean" / img_path.name

        if clean_path.exists():
            print(f"\n--- Processing: {img_path.name} ---")
            
            try:
                with Image.open(img_path) as orig_img, Image.open(clean_path) as clean_img:
                    # Ensure RGBA for transparency handling
                    orig_img = orig_img.convert("RGBA")
                    clean_img = clean_img.convert("RGBA")

                    # 1. Calculate dimensions and ratio
                    clean_w, clean_h = clean_img.size
                    orig_w, orig_h = orig_img.size
                    
                    # "Square of bottom right pixels that is 10 percent the width of the image"
                    crop_size = int(clean_w * 0.10)
                    
                    print(f"Original Size: {orig_w}x{orig_h}")
                    print(f"Clean Size:    {clean_w}x{clean_h}")
                    print(f"Base Crop Size (10% of clean width): {crop_size}px")
                    
                    # Define crop box (Left, Top, Right, Bottom)
                    box = (clean_w - crop_size, clean_h - crop_size, clean_w, clean_h)
                    
                    # Extract the square patch
                    clean_patch = clean_img.crop(box)

                    # 2. Enlarge extracted pixels by ratio of -clean to original
                    ratio = orig_w / clean_w
                    new_patch_size = int(crop_size * ratio)
                    
                    print(f"Scaling Ratio: {ratio:.4f}")
                    print(f"Final Patch Size: {new_patch_size}x{new_patch_size}px")
                    
                    # Resize the patch using high-quality resampling (LANCZOS)
                    clean_patch_resized = clean_patch.resize((new_patch_size, new_patch_size), Image.Resampling.LANCZOS)

                    # 3. Prepare for Overlay
                    # Coordinates to paste onto original (Bottom Right)
                    paste_x = orig_w - new_patch_size
                    paste_y = orig_h - new_patch_size
                    print(f"Paste Coords: ({paste_x}, {paste_y})")
                    
                    # Extract the background from the original image to blend with
                    dest_crop = orig_img.crop((paste_x, paste_y, orig_w, orig_h))
                    
                    # 4. Darken Blending
                    # Compare pixels and keep the darker ones
                    blended_patch = ImageChops.darker(dest_crop, clean_patch_resized)

                    # 5. Feathering (Gradient Mask Approach)
                    # Increased to 33% as requested
                    feather_dist = int(new_patch_size * 0.33) 
                    feather_dist = max(1, feather_dist)
                    
                    print(f"Feather Distance: {feather_dist}px")

                    # Create base mask (solid white)
                    mask = Image.new("L", (new_patch_size, new_patch_size), 255)
                    
                    if feather_dist > 0:
                        # -- Horizontal Gradient Source --
                        # 0 (Black) on left -> 255 (White) on right
                        gradient_source_h = Image.new("L", (256, 1))
                        for i in range(256):
                            gradient_source_h.putpixel((i, 0), i)

                        # -- Vertical Gradient Source --
                        # 0 (Black) on top -> 255 (White) on bottom
                        gradient_source_v = Image.new("L", (1, 256))
                        for i in range(256):
                            gradient_source_v.putpixel((0, i), i)
                        
                        # -- Horizontal Mask (Left Edge Fade) --
                        # Resize horizontal gradient to (feather_dist, 1)
                        h_grad = gradient_source_h.resize((feather_dist, 1), Image.Resampling.BILINEAR)
                        
                        # Create a row that is [Gradient] + [White Rest of Width]
                        h_mask_row = Image.new("L", (new_patch_size, 1), 255)
                        h_mask_row.paste(h_grad, (0, 0)) # Paste gradient at start (Left)
                        
                        # Stretch this row to full height
                        mask_x = h_mask_row.resize((new_patch_size, new_patch_size), Image.Resampling.NEAREST)
                        
                        # -- Vertical Mask (Top Edge Fade) --
                        # Resize vertical gradient to (1, feather_dist)
                        v_grad = gradient_source_v.resize((1, feather_dist), Image.Resampling.BILINEAR)
                        
                        # Create a col that is [Gradient] + [White Rest of Height]
                        v_mask_col = Image.new("L", (1, new_patch_size), 255)
                        v_mask_col.paste(v_grad, (0, 0)) # Paste gradient at start (Top)
                        
                        # Stretch this col to full width
                        mask_y = v_mask_col.resize((new_patch_size, new_patch_size), Image.Resampling.NEAREST)
                        
                        # Combine masks
                        mask = ImageChops.multiply(mask_x, mask_y)

                    if SAVE_INTERMEDIATE:
                        debug_mask_name = folder / f"debug_mask_{img_path.stem}.png"
                        debug_patch_name = folder / f"debug_patch_{img_path.stem}.png"
                        debug_blended_name = folder / f"debug_blended_{img_path.stem}.png"
                        
                        mask.save(debug_mask_name)
                        clean_patch_resized.save(debug_patch_name)
                        blended_patch.save(debug_blended_name)
                        print(f"Debug saved: {debug_mask_name.name}, {debug_patch_name.name}")

                    # Composite the blended patch onto the original using the feathered mask
                    orig_img.paste(blended_patch, (paste_x, paste_y), mask)

                    # 6. Save Logic
                    temp_png = folder / "temp_processing.png"
                    orig_img.save(temp_png)

                # Move original image to 'orig' folder
                shutil.move(str(img_path), str(orig_folder / img_path.name))
                print(f"Moved source to ./orig/{img_path.name}")

                # 7. Convert to WebP
                output_webp = folder / f"{img_path.stem}.webp"
                print(f"Encoding {output_webp.name}...")
                
                cmd = [
                    cwebp_path,
                    "-q", "100",        # Quality 100
                    "-m", "6",          # Method 6 (slowest, best compression)
                    "-mt",              # Multi-threading
                    "-lossless",        # Lossless mode
                    "-progress",        # Show progress
                    str(temp_png),
                    "-o", str(output_webp)
                ]
                
                # subprocess.run will inherit stdout/stderr, so progress should show in console
                subprocess.run(cmd, check=True)
                print(f"Finished {output_webp.name}")

                # Clean up temp file
                if temp_png.exists():
                    os.remove(temp_png)

            except Exception as e:
                print(f"ERROR processing {img_path.name}: {e}")
                # Clean up temp file on error too
                temp_png_err = folder / "temp_processing.png"
                if temp_png_err.exists():
                    os.remove(temp_png_err)

if __name__ == "__main__":
    process_images(".")