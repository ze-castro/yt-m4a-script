#!/bin/zsh
# Ensure yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
  echo "Error: yt-dlp is not installed! Please install yt-dlp before running this script."
  exit 1
fi
# Get the base directory in Downloads
BASE_DIR="$HOME/Downloads"
# Get cookies from browser (Firefox by default)
BROWSER="firefox"
echo "Getting cookies from $BROWSER browser..."
yt-dlp --cookies-from-browser $BROWSER --cookies youtube.cookies.txt -f "bestaudio" --skip-download "https://www.youtube.com"
if [ ! -f youtube.cookies.txt ]; then
  echo "Error: Failed to get cookies! Make sure you are logged into YouTube in your browser."
  exit 1
fi
echo "Successfully retrieved cookies from $BROWSER"
# Ask user for input
echo -n "Enter YouTube Playlist or Song URL: "
read url
if [[ -z "$url" ]]; then
  echo "Error: Invalid input. You must provide a song or playlist URL."
  exit 1
fi
# Create folder if it doesn't exist
mkdir -p "$BASE_DIR/music"
echo "Downloading from URL: $url"
# Download using yt-dlp
yt-dlp -x --audio-format mp3 \
  --embed-thumbnail \
  --embed-metadata \
  --add-metadata \
  --cookies youtube.cookies.txt \
  --metadata-from-title "%(title)s" \
  -o "$BASE_DIR/music/%(title)s.%(ext)s" \
  "$url"
echo "Download complete!"
# Process downloaded files
for file in "$BASE_DIR/music/"*.mp3; do
  if [ ! -f "$file" ]; then
    continue
  fi
  # Extract metadata using ffprobe (from ffmpeg package)
  artist=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
  if [[ -n "$artist" ]]; then
    # Keep only the first artist name
    clean_artist=$(echo "$artist" | sed -E 's/,.*//')
    # Sanitize filename:
    original_filename=$(basename "$file" .mp3)
    echo "Original: $original_filename"
    
    # Process in a specific order to avoid whitespace issues
    # 1. First remove everything inside parentheses including the parentheses
    temp_filename=$(echo "$original_filename" | sed -E 's/\([^)]*\)//g')
    echo "After parentheses removal: '$temp_filename'"
    
    # 2. Remove the artist's name and dash (for patterns like "Artist - Title")
    temp_filename=$(echo "$temp_filename" | sed -E 's/^[^-]+ - //g')
    echo "After artist removal: '$temp_filename'"
    
    # 3. Remove multiple spaces and trim whitespace
    sanitized_filename=$(echo "$temp_filename" | tr -s ' ' | sed -E 's/^ +| +$//g')
    echo "After whitespace cleanup: '$sanitized_filename'"
    
    # Ensure .mp3 extension
    sanitized_filename="${sanitized_filename}.mp3"
    
    # Rename file
    new_file="${file%/*}/$sanitized_filename"
    mv "$file" "$new_file"
    echo "Sanitized filename: $file -> $new_file"
    
    # Update metadata with only one artist name
    ffmpeg -i "$new_file" -metadata artist="$clean_artist" -metadata title="${sanitized_filename%.mp3}" -codec copy "${new_file%.mp3}_temp.mp3"
    mv "${new_file%.mp3}_temp.mp3" "$new_file"
    echo "Updated metadata for: $new_file"
  else
    echo "Error: Failed to extract artist metadata for $file. Skipping..."
    continue
  fi
done
echo "Sanitization complete!"
# Cleanup
rm -f youtube.cookies.txt
echo "All tasks completed successfully!"