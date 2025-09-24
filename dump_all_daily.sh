#!/bin/bash

# Correct date assignment
current_date=$(date +%Y-%m-%d)

# Directory to search in
source_dir="/home/backup" # replace w/ your dir

# CHOSE ! Archive destination
#$1 - passes the destination dir for full backup archive via terminal
#dest_dir="$1"
dest_dir="/mnt"


# Days ago to check
days_ago=1
found_files=()

# Find files and directories modified within the last $days_ago days,
# excluding nextcloud data and the destination directory

while IFS= read -r -d $'\0' file; do
  found_files+=("$file")
done < <(find "$source_dir"  -path "${dest_dir}" -prune \ 
  -o -path "${source_dir}/dir_to_exclude" -prune \
  -o \( -name "*.tar" -o -name "*.gz" -o -name "*.7z" -o -name "*.zip" -o -name "*.bak" -o -name "*.trn" \) \
  -a -mtime -$days_ago -print0)


#custom add Sklad1C files
while IFS= read -r -d $'\0' file; do
  found_files+=("$file")
done < <(find "${source_dir}/specific_dir/"  \( -name "*.tar" -o -name "*.gz" -o -name "*.7z" -o -name "*.zip" -o -name "*.bak" -o -name "*.trn" \) \
  -a -mtime -2 -print0) # edit -mtime for your case & dir name

# Create destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Create a unique monolithic archive name
archive_name="${dest_dir}/dump_$(date +%Y%m%d%H%M%S).tar.gz"

#Debug

# Calculate total size (optional)
#total_size=0
#for file in "${found_files[@]}"; do
#  if [ -f "$file" ]; then # Check if it's a regular file
#    file_size=$(stat -c %s "$file") # Get the size in bytes
#    total_size=$((total_size + file_size)) # Add to the total
#  fi
#done

# Output the total size (optional)
# if [ "$total_size" -gt 0 ]; then
#   echo "Total size of files to archive: $total_size bytes"
#
#   # Optional: Convert to human-readable format (using 'numfmt')
#   if command -v numfmt &> /dev/null; then
#     human_size=$(numfmt --to=iec --suffix=B --format="%.2f" "$total_size")
#     echo "Total size (human): $human_size"
#   fi
# fi

# Archive all found files and directories
if [ ${#found_files[@]} -gt 0 ]; then
  echo "Archiving ${#found_files[@]} files and directories..." >> "${dest_dir}/log_dailydump.txt"
  tar -czvf "$archive_name" "${found_files[@]}" > "${dest_dir}/log_dailydump.txt" 2>&1 # Redirect both stdout and stderr to log
  if [ $? -eq 0 ]; then
    echo "Monolithic archive created successfully: $archive_name" >> "${dest_dir}/log_dailydump.txt"
  else
    echo "Error creating monolithic archive. See log file for details: ${dest_dir}/log_dailydump.txt" >> "${dest_dir}/log_dailydump.txt"
  fi
else
  echo "No files or directories found within the last $days_ago days." >> "${dest_dir}/log_dailydump.txt"
fi
echo " Archiving process complete. "
