#!/bin/bash

# Directory containing the Word documents
input_dir="./Mechanics_FRQ/Scoring Guidelines"

# Directory for the output
output_base_dir="./Mechanics_FRQ-md/Scoring_Guidelines"

# Create output directory if it doesn't exist
mkdir -p "$output_base_dir"

# Process each .docx file
for docx_file in "$input_dir"/*.docx; do
    # Get just the filename without extension
    filename=$(basename "$docx_file" .docx)
    
    # Create a directory for this document's output
    doc_output_dir="$output_base_dir/$filename"
    mkdir -p "$doc_output_dir"
    
    # Convert the document
    echo "Converting $filename.docx..."
    pandoc "$docx_file" -o "$doc_output_dir/$filename.md" --extract-media="$doc_output_dir"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' "s|$doc_output_dir/media|media|g" "$doc_output_dir/$filename.md"
    else
        # Linux version
        sed -i "s|$doc_output_dir/media|media|g" "$doc_output_dir/$filename.md"
    fi
    echo "Done: $filename"
done

echo "All documents converted successfully!"