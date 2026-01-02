import os
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter

# --- Configuration ---
SOURCE_FOLDER = '.'          # Current folder, or change to e.g., 'C:/Images'
OUTPUT_FOLDER = './merged'   # Folder to save results
CROP_SIZE = 200              # Size of the square to copy
FEATHER_PIXELS = 10          # Size of the feather gradient

def create_corner_mask(size, feather):
    """
    Creates an L-mode (grayscale) mask that is white (opaque) in the center
    and fades to black (transparent) on the Top and Left edges.
    """
    width, height = size
    
    # Start with a fully opaque mask
    mask = Image.new('L', size, 255)
    draw = ImageDraw.Draw(mask)
    
    # 1. Feather the TOP edge
    # Draw horizontal lines with increasing opacity from 0 to 255
    for y in range(feather):
        opacity = int((y / feather) * 255)
        draw.line([(0, y), (width, y)], fill=opacity)

    # 2. Feather the LEFT edge
    # Draw vertical lines with increasing opacity from 0 to 255
    # We use min() to ensure we don't overwrite the top feathering with a harder edge
    # if the gradient logic overlaps.
    for x in range(feather):
        opacity = int((x / feather) * 255)
        # We need to process pixel by pixel for the intersection corner 
        # or just draw lines. Vertical lines are easier.
        # To blend the top-left corner correctly, we get the existing pixel 
        # and multiply or take the minimum opacity.
        for y in range(height):
            existing_val = mask.getpixel((x, y))
            new_val = opacity
            # Use the darker (more transparent) of the two values to ensure smooth corner
            final_val = min(existing_val, new_val) 
            mask.putpixel((x, y), final_val)

    return mask

def process_images():
    # Ensure output directory exists
    output_path = Path(OUTPUT_FOLDER)
    output_path.mkdir(parents=True, exist_ok=True)
    
    source_path = Path(SOURCE_FOLDER)
    
    # Get all PNG files
    png_files = list(source_path.glob('*.png'))
    
    print(f"Scanning {source_path.resolve()}...")

    # Identify pairs
    # We look for files ending in "-clean.png"
    for clean_file in png_files:
        if clean_file.name.endswith('-clean.png'):
            base_name = clean_file.name.replace('-clean.png', '.png')
            base_file = source_path / base_name
            
            if base_file.exists():
                save_path = output_path / base_name
                if save_path.exists():
                    print(f"Skipping '{base_name}', already exists in output.")
                    continue
                print(f"Processing pair: '{base_name} + {clean_file.name}'")
                
                try:
                    # Open images
                    with Image.open(base_file).convert("RGBA") as img_base, \
                         Image.open(clean_file).convert("RGBA") as img_clean:
                        
                        # 1. Resize clean image to match base image
                        if img_clean.size != img_base.size:
                            img_clean = img_clean.resize(img_base.size, Image.Resampling.LANCZOS)
                        
                        # Calculate coordinates for lower-right corner
                        # Box = (left, upper, right, lower)
                        w, h = img_base.size
                        box = (w - CROP_SIZE, h - CROP_SIZE, w, h)
                        
                        # 2. Extract crops
                        crop_base = img_base.crop(box)
                        crop_clean = img_clean.crop(box)
                        
                        # 3. Create the "Darken" blend
                        # ImageChops.darker compares pixels and keeps the darker one
                        merged_crop = ImageChops.darker(crop_base, crop_clean)
                        
                        # 4. Generate the feather mask
                        # The mask defines WHERE we paste the new merged_crop onto the original
                        mask = create_corner_mask((CROP_SIZE, CROP_SIZE), FEATHER_PIXELS)
                        
                        # 5. Paste the merged crop onto the original image using the mask
                        # This overlays the darker-blended corner onto the original base
                        # The mask ensures the top and left edges of this square fade in smoothly
                        final_image = img_base.copy()
                        final_image.paste(merged_crop, box, mask=mask)
                        
                        # Save result                        
                        final_image.save(save_path)
                        print(f"  -> Saved to '{save_path}'")
                        
                except Exception as e:
                    print(f"  ERROR processing {base_name}: {e}")

if __name__ == "__main__":
    process_images()