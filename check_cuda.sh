#!/bin/bash
# Define target directory
target_dir="/usr/local/"

# Flags to track versions
found_cuda_12_3=0
found_other_versions=0

# Find directories that match the pattern
while IFS= read -r -d $'\0' dir; do
  if [[ "$dir" =~ ^/usr/local/cuda-12\.[0-9]+$ ]]; then
    if [[ "$dir" == "/usr/local/cuda-12.3" ]]; then
      found_cuda_12_3=1
    elif [[ "$dir" != "/usr/local/cuda-12.3" ]]; then
      found_other_versions=1
      echo "Found directory to remove: $dir"
      # Add removal command
      rm -rf "$dir"
      echo "Directory $dir has been removed."
    fi
  fi
done < <(find "$target_dir" -mindepth 1 -maxdepth 1 -name "cuda-12.*" -print0)

# Check if any version was found
if [[ $found_cuda_12_3 -eq 0 ]]; then
  echo "cuda-12.3 needs to be installed."
  . ./install_cuda.sh
elif [[ $found_cuda_12_3 -eq 1 ]]; then
  echo "cuda-12.3 already exists."
fi
if [[ $found_other_versions -eq 0 ]]; then
  echo "There is no other version of CUDA, no need to delete."
fi