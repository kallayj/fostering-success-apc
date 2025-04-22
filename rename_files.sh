#\!/bin/bash

# Function to rename files and directories in a given path
rename_files_and_dirs() {
  local path=$1
  local type=$2  # "EM" or "Mechanics"
  local prefix=$3  # "Wisusik" or "Wisuisik"
  
  # For directories
  find "$path" -type d -name "*${prefix}*"  < /dev/null |  while read dir; do
    # Skip if directory is a parent directory that contains other matching directories
    if find "$dir" -mindepth 1 -type d -name "*${prefix}*" | grep -q .; then
      continue
    fi
    
    # Get the new name
    base=$(basename "$dir")
    parent=$(dirname "$dir")
    
    # Replace format: [prefix].CLASS.TYPE.NUM to CLASS-TYPE-NUM
    if [[ "$base" =~ (Copy\ of\ )?(\(SG\)\ )?(${prefix})\.([^.]+)\.([^.]+)\.([^\ ]+)(.*) ]]; then
      prefix_part="${BASH_REMATCH[1]}"
      sg_part="${BASH_REMATCH[2]}"
      class="${BASH_REMATCH[4]}"
      type="${BASH_REMATCH[5]}"
      num="${BASH_REMATCH[6]}"
      title="${BASH_REMATCH[7]}"
      
      # Create new directory name
      new_dir_name="${sg_part}${class}-${type}-${num}${title}"
      new_dir_path="$parent/$new_dir_name"
      
      echo "Renaming directory: $dir -> $new_dir_path"
      mv "$dir" "$new_dir_path"
    fi
  done
  
  # For files
  find "$path" -type f -name "*${prefix}*" | while read file; do
    base=$(basename "$file")
    parent=$(dirname "$file")
    
    # Replace format: [prefix].CLASS.TYPE.NUM to CLASS-TYPE-NUM
    if [[ "$base" =~ (Copy\ of\ )?(\(SG\)\ )?(${prefix})\.([^.]+)\.([^.]+)\.([^\ ]+)(.*)(\.md) ]]; then
      prefix_part="${BASH_REMATCH[1]}"
      sg_part="${BASH_REMATCH[2]}"
      class="${BASH_REMATCH[4]}"
      type="${BASH_REMATCH[5]}"
      num="${BASH_REMATCH[6]}"
      title="${BASH_REMATCH[7]}"
      ext="${BASH_REMATCH[8]}"
      
      # Create new file name
      new_file_name="${sg_part}${class}-${type}-${num}${title}${ext}"
      new_file_path="$parent/$new_file_name"
      
      echo "Renaming file: $file -> $new_file_path"
      mv "$file" "$new_file_path"
    fi
  done
}

# Rename files in EM_FRQ
# rename_files_and_dirs "/home/yoni/source/fostering-success-apc/EM_FRQ" "EM" "Wisusik"

# Rename files in Mechanics_FRQ
rename_files_and_dirs "/home/yoni/source/fostering-success-apc/Mechanics_FRQ/Scoring_Guidelines" "Mechanics" "Wisusik"

echo "Renaming complete"
