#!/bin/bash
# Script to download solution files from Google Drive and update index files

# Base directory
BASE_DIR="/home/yoni/source/fostering-success-apc"
# Directory to store solutions
SOLUTIONS_DIR="$BASE_DIR/Solutions"
# EM_FRQ and Mechanics_FRQ directories
EM_FRQ_DIR="$BASE_DIR/EM_FRQ"
MECH_FRQ_DIR="$BASE_DIR/Mechanics_FRQ"

# Create solutions directory if it doesn't exist
mkdir -p "$SOLUTIONS_DIR/EM"
mkdir -p "$SOLUTIONS_DIR/Mechanics"

# Function to extract file ID from Google Drive URL
extract_file_id() {
    local url=$1
    # Extract the ID from various Google Drive URL formats
    if [[ $url == *"drive.google.com/open"* ]]; then
        echo "$url" | sed -n 's/.*id=\([^&]*\).*/\1/p'
    elif [[ $url == *"drive.google.com/file/d/"* ]]; then
        echo "$url" | sed -n 's/.*file\/d\/\([^\/]*\).*/\1/p'
    else
        echo "Invalid Google Drive URL format: $url" >&2
        return 1
    fi
}

# Function to download a file from Google Drive
download_from_gdrive() {
    local file_id=$1
    local output_file=$2
    
    echo "Downloading $output_file..."
    
    # Using curl to download files from Google Drive
    # Note: This method might not work for all files, especially larger ones
    # that require authentication
    
    # First get a confirmation token
    #local confirm=$(curl -s -L "https://drive.google.com/uc?export=download&id=$file_id" | 
    #              grep -o 'confirm=[^&]*' | sed 's/confirm=//')
    
    #if [ -n "$confirm" ]; then
        # If we have a token, use it to download
        #curl -L "https://drive.google.com/uc?export=download&confirm=t&id=$file_id" -o "$output_file"
    echo "https://drive.google.com/uc?export=download&confirm=t&id=$file_id"
    #else
        # Try direct download
    #    curl -L "https://drive.google.com/uc?export=download&id=$file_id" -o "$output_file"
    #fi
    
    # Check if download was successful
    # if [ $? -ne 0 ] || [ ! -s "$output_file" ]; then
    #     echo "Warning: Failed to download $output_file with file_id=$file_id" >&2
    #     echo "You may need to download this file manually." >&2
    #     # Create an empty placeholder file
    #     touch "$output_file"
    #     echo "[PLACEHOLDER - Manual download required]" > "$output_file"
    #     return 1
    # else
    #     echo "Successfully downloaded $output_file"
    #     return 0
    # fi
}

# Function to process index file and update links
update_index_file() {
    local file=$1
    local temp_file="${file}.tmp"
    local category=$(basename "$file" .md)
    local dir_type=""
    
    # Determine if this is for EM or Mechanics
    if [[ $category == emag* ]]; then
        dir_type="EM"
    else
        dir_type="Mechanics"
    fi
    
    echo "Processing $file..."
    
    # Read through file line by line
    while IFS= read -r line; do
        if [[ $line == *"Solutions"*"drive.google.com"* ]]; then
            # Extract the Question ID, file name, and Google Drive link
            question_id=$(echo "$line" | grep -o 'Wisusik\.[A-Z]*\.[A-Z]*\.[0-9]*')
            if [ -z "$question_id" ]; then
                # Try Wisuisik (note the different spelling in some files)
                question_id=$(echo "$line" | grep -o 'Wisuisik\.[A-Z]*\.[A-Z]*\.[0-9]*')
            fi
            
            solution_link=$(echo "$line" | grep -o 'https://drive.google.com[^)]*')
            file_id=$(extract_file_id "$solution_link")
            
            # Create appropriate directory and file name
            solution_dir="$SOLUTIONS_DIR/$dir_type/$question_id"
            mkdir -p "$solution_dir"
            solution_file="$solution_dir/solution.pdf"
            
            # Download the solution file
            if [ -n "$file_id" ]; then
                download_from_gdrive "$file_id" "$solution_file"
                
                # Replace Google Drive link with local link in the index file
                # Format: [Solutions](/path/to/local/file)
                local_link="[Solutions](/$solution_file)"
                # Replace with proper link
                line=${line/\[Solutions\]\([^)]*\)/$local_link}
            else
                echo "Warning: Could not extract file ID for $question_id" >&2
            fi
        fi
        
        # # Replace problem and scoring guideline links
        # if [[ $line == *"docs.google.com/document"* ]]; then
        #     # Replace problem Google Drive link with local file
        #     problem_title=$(echo "$line" | grep -o '\[[^]]*\]' | head -1 | tr -d '[]')
        #     question_id=$(echo "$line" | grep -o 'Wisusik\.[A-Z]*\.[A-Z]*\.[0-9]*' | head -1)
        #     if [ -z "$question_id" ]; then
        #         question_id=$(echo "$line" | grep -o 'Wisuisik\.[A-Z]*\.[A-Z]*\.[0-9]*' | head -1)
        #     fi
            
        #     if [ -n "$question_id" ]; then
        #         local_problem_path=""
        #         if [[ $dir_type == "EM" ]]; then
        #             local_problem_path="/EM_FRQ/Copy of $question_id"
        #             if [[ -d "$EM_FRQ_DIR/Copy of $question_id ($problem_title)" ]]; then
        #                 local_problem_path="/EM_FRQ/Copy of $question_id ($problem_title)/Copy of $question_id ($problem_title).md"
        #             else
        #                 local_problem_path="/EM_FRQ/Copy of $question_id/Copy of $question_id.md"
        #             fi
        #         else
        #             local_problem_path="/Mechanics_FRQ/$question_id"
        #             if [[ -d "$MECH_FRQ_DIR/$question_id ($problem_title)" ]]; then
        #                 local_problem_path="/Mechanics_FRQ/$question_id ($problem_title)/$question_id ($problem_title).md"
        #             else
        #                 local_problem_path="/Mechanics_FRQ/$question_id/$question_id.md"
        #             fi
        #         fi
                
        #         # Only replace if local file exists
        #         if [[ -f "$BASE_DIR$local_problem_path" ]]; then
        #             line=$(echo "$line" | sed "s|\[\([^]]*\)\](https://docs.google.com[^)]*)|\[\1\]($local_problem_path)|")
        #         fi
        #     fi
        # fi
        
        # if [[ $line == *"Scoring Guidelines"*"drive.google.com"* ]]; then
        #     # Replace scoring guideline link with local path
        #     question_id=$(echo "$line" | grep -o 'Wisusik\.[A-Z]*\.[A-Z]*\.[0-9]*')
        #     if [ -z "$question_id" ]; then
        #         question_id=$(echo "$line" | grep -o 'Wisuisik\.[A-Z]*\.[A-Z]*\.[0-9]*')
        #     fi
            
        #     local_sg_path=""
        #     if [[ $dir_type == "EM" ]]; then
        #         local_sg_path="/EM_FRQ/Scoring_Guidelines/Copy of (SG) $question_id/Copy of (SG) $question_id.md"
        #     else
        #         local_sg_path="/Mechanics_FRQ/Scoring_Guidelines/(SG) $question_id/(SG) $question_id.md"
        #     fi
            
        #     # Only replace if local file exists
        #     if [[ -f "$BASE_DIR$local_sg_path" ]]; then
        #         line=$(echo "$line" | sed "s|\[Scoring Guidelines\](https://drive.google.com[^)]*)|\[Scoring Guidelines\]($local_sg_path)|")
        #     fi
        # fi
        
        # # Write the updated line to the temp file
        # echo "$line" >> "$temp_file"
    done < "$file"
    
    # Replace the original file with the updated one
    #mv "$temp_file" "$file"
    #echo "Updated $file"
}

# Main script execution

# Process all index files
echo "Updating index files..."
index_files=(
    "$BASE_DIR/emag_lab.md"
    "$BASE_DIR/emag_mr.md"
    "$BASE_DIR/emag_other.md"
    "$BASE_DIR/emag_tbr.md"
    "$BASE_DIR/motion_forces.md"
    "$BASE_DIR/rotation_shm.md"
    "$BASE_DIR/conservation.md"
)

for index_file in "${index_files[@]}"; do
    update_index_file "$index_file"
done

echo "All done!"
echo ""
echo "Note: Downloading files directly from Google Drive can be challenging due to:"
echo "1. Authentication requirements for some files"
echo "2. Rate limiting for larger files or multiple downloads"
echo "3. Drive API changes that may break direct download methods"
echo ""
echo "If some downloads failed, you may need to:"
echo "1. Manually download files using a browser"
echo "2. Use the Google Drive API with proper authentication"
echo "3. Use 'gdown' Python package which has better Google Drive support"
echo "4. Consider a different hosting solution for easier downloads"
echo ""
echo "Files that failed to download will contain placeholder text."