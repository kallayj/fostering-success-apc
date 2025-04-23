#!/bin/bash

# Script to generate a static website from Markdown files in Mechanics_FRQ

# Base directories
BASE_DIR="$(pwd)"
INPUT_DIR="${BASE_DIR}/Mechanics_FRQ"
OUTPUT_DIR="${BASE_DIR}/Mechanics_Website"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy the common assets
mkdir -p "$OUTPUT_DIR/common"
cp -r "${BASE_DIR}/common/"* "$OUTPUT_DIR/common/"

# Function to convert a markdown file to HTML
convert_markdown_to_html() {
    local md_file="$1"
    local output_path="$2"
    local dir_name="$(dirname "$output_path")"
    
    # Create output directory if it doesn't exist
    mkdir -p "$dir_name"
    
    # Convert markdown to HTML using pandoc
    pandoc "$md_file" \
        --standalone \
        --from markdown \
        --to html \
        --output "$output_path" \
        --css "/common/style.css"    
    # Fix links from .md to .html
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' 's/\.md"/\.html"/g' "$output_path"
        sed -i '' 's/\.md#/\.html#/g' "$output_path"
        # Fix index.html links
        sed -i '' 's/\/index\.html"/\/"/' "$output_path"
        # Fix references to common folder
        sed -i '' 's/\.\.\/.\.\.\/common\//\/common\//g' "$output_path"
    else
        # Linux version
        sed -i 's/\.md"/\.html"/g' "$output_path"
        sed -i 's/\.md#/\.html#/g' "$output_path"
        # Fix index.html links
        sed -i 's/\/index\.html"/\/"/' "$output_path"
        # Fix references to common folder
        sed -i 's/\.\.\/.\.\.\/common\//\/common\//g' "$output_path"
    fi
    
    echo "Converted: $md_file -> $output_path"
}

# Create a basic CSS file if it doesn't exist
mkdir -p "$OUTPUT_DIR/common"
if [ ! -f "$OUTPUT_DIR/common/style.css" ]; then
    cat > "$OUTPUT_DIR/common/style.css" << 'EOF'
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
    color: #333;
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    color: #2c3e50;
}

a {
    color: #3498db;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}

th {
    background-color: #f2f2f2;
}

img {
    max-width: 100%;
    height: auto;
}

code, pre {
    background-color: #f8f8f8;
    border: 1px solid #ddd;
    border-radius: 3px;
    padding: 2px 5px;
    font-family: monospace;
}

pre {
    padding: 10px;
    overflow-x: auto;
}

blockquote {
    border-left: 4px solid #ddd;
    padding-left: 10px;
    color: #666;
}
EOF
    echo "Created basic CSS file at $OUTPUT_DIR/common/style.css"
fi

# Process all markdown files
echo "Converting Markdown files to HTML..."
find "$INPUT_DIR" -name "*.md" | while read -r md_file; do
    # Get the relative path
    rel_path="${md_file#$INPUT_DIR/}"
    # Create the output path
    output_path="$OUTPUT_DIR/${rel_path%.md}.html"
    convert_markdown_to_html "$md_file" "$output_path"
done

# Copy all media directories and files
echo "Copying media files..."
find "$INPUT_DIR" -type d -name "media" | while read -r media_dir; do
    # Get the relative path
    rel_path="${media_dir#$INPUT_DIR/}"
    # Create the output path
    output_media_dir="$OUTPUT_DIR/$rel_path"
    # Copy the media directory
    mkdir -p "$output_media_dir"
    cp -r "$media_dir/"* "$output_media_dir/"
    echo "Copied media from: $media_dir -> $output_media_dir"
done

echo "Website generated successfully at $OUTPUT_DIR"
echo "You can view it by opening $OUTPUT_DIR/index.html in your browser"