#!/bin/bash

# Ensure `aseprite` is available
if ! command -v aseprite &> /dev/null; then
  echo "Error: aseprite command not found."
  exit 1
fi

# Function to convert .aseprite to .png
convert_files() {
  local dir="$1"
  # Find all .aseprite files in the given directory and its subdirectories
  find "$dir" -type f -name "*.aseprite" | while read -r aseprite_file; do
    # Determine the output PNG path
    output_file="${aseprite_file%.aseprite}.png"
    
    # Convert .aseprite to .png
    aseprite -b "$aseprite_file" --save-as "$output_file"
    
    # Check for success
    if [ $? -eq 0 ]; then
      echo "Converted: $aseprite_file -> $output_file"
    else
      echo "Failed to convert: $aseprite_file"
    fi
  done
}

# Main script
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

input_dir="$1"

# Check if input is a valid directory
if [ ! -d "$input_dir" ]; then
  echo "Error: $input_dir is not a valid directory."
  exit 1
fi

# Start the conversion process
convert_files "$input_dir"

