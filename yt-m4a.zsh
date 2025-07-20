#!/bin/zsh

# CONFIGURATION
# Directory to save downloaded music
MUSIC_DIR="$HOME/Downloads/music"

# Your preferred browser (e.g., chrome, firefox, safari)
BROWSER="safari"

# Location to store cookies
COOKIES_FILE="$HOME/Downloads/youtube.cookies.txt"

# Music Quality (0 = best, 10 = worst)
MUSIC_QUALITY=0

# Global variable for sanitization mode
SANITIZATION_MODE=""

# FUNCTIONS
check_dependencies() {
  if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp is not installed! Please install yt-dlp before running this script."
    exit 1
  fi
  
  if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed! Please install ffmpeg before running this script."
    exit 1
  fi
}

get_browser_cookies() {
  echo "Getting cookies from $BROWSER browser..."
  yt-dlp --cookies-from-browser $BROWSER --cookies "$COOKIES_FILE" --flat-playlist --quiet --no-warnings "https://www.youtube.com"

  if [ ! -f $COOKIES_FILE ]; then
    echo "Error: Failed to get cookies! Make sure you are logged into YouTube in your browser."
    exit 1
  fi
  
  echo "Successfully retrieved cookies from $BROWSER"
}

get_download_type() {
  echo -n "Are you downloading unformatted audio? (y/n): "
  read download_type
  
  case $download_type in
    (y|Y|yes|Yes)
      SANITIZATION_MODE="hard"
      echo "Unformatted audio mode selected - using hard sanitization"
      ;;
    (n|N|no|No)
      SANITIZATION_MODE="soft"
      echo "Video mode selected - using soft sanitization"
      ;;
    (*)
      echo "Invalid choice. Defaulting to hard sanitization"
      SANITIZATION_MODE="hard"
      ;;
  esac
}

get_youtube_url() {
  echo -n "Enter YouTube Playlist or Song URL (or 'q' to quit): "
  read url

  if [[ "$url" == "q" ]]; then
    return 1
  fi
  
  if [[ -z "$url" ]]; then
    echo "Error: Invalid input. You must provide a song or playlist URL."
    return 1
  fi

  echo "Downloading from URL: $url"
  return 0
}

download_audio() {
  local url=$1
  local music_dir="$MUSIC_DIR/%(playlist_index)02d. %(title)s.%(ext)s"

  if [[ "$SANITIZATION_MODE" == "hard" ]]; then
    music_dir="$MUSIC_DIR/%(title)s.%(ext)s"
  fi

  mkdir -p "$MUSIC_DIR"
  yt-dlp -x --audio-format aac \
    --audio-quality $MUSIC_QUALITY \
    --embed-thumbnail \
    --embed-metadata \
    --add-metadata \
    --cookies $COOKIES_FILE \
    -o "$music_dir" \
    "$url"
    
  echo "Download complete!"
}

sanitize_filename() {
  local original_filename=$1

  local clean_filename=$(echo "$original_filename" | sed -E 's/\[[^]]*\]//g')
  clean_filename=$(echo "$clean_filename" | sed -E $'s/[|｜/].*$//')
  clean_filename=$(echo "$clean_filename" | sed -E 's/^[^-]+ - //g')

  if [[ "$SANITIZATION_MODE" == "hard" ]]; then
    clean_filename=$(echo "$clean_filename" | sed -E 's/\([^)]*\)//g')
  fi

  clean_filename=$(echo "$clean_filename" | tr -s ' ' | sed -E 's/^ +| +$//g')
  
  echo "${clean_filename}"
}

update_metadata() {
  local file_path=$1
  local clean_artist=$2
  local sanitized_title=${3%.m4a}

  ffmpeg -i "$file_path" \
    -metadata artist="$clean_artist" \
    -metadata title="$sanitized_title" \
    -codec copy "${file_path%.m4a}_temp.m4a"
  
  mv "${file_path%.m4a}_temp.m4a" "$file_path"

  process_thumbnail "$file_path"

  echo "Updated metadata and artwork for: $file_path"
}

process_thumbnail() {
  local file_path=$1
  local temp_thumb="${file_path%.m4a}_thumb.jpg"
  local square_thumb="${file_path%.m4a}_square.jpg"
  
  ffmpeg -i "$file_path" -an -vcodec copy "$temp_thumb" -v quiet -y 2>/dev/null
  
  if [[ -f "$temp_thumb" ]]; then
    local width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$temp_thumb")
    local height=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$temp_thumb")
    local size=$((width > height ? height : width))
    
    ffmpeg -i "$temp_thumb" \
      -vf "crop=$size:$size:(iw-$size)/2:(ih-$size)/2" \
      -q:v 2 "$square_thumb" -v quiet -y 2>/dev/null
    
    if [[ -f "$square_thumb" ]]; then
      ffmpeg -i "$file_path" -i "$square_thumb" \
        -map 0:a -map 1:v -c:a copy -c:v mjpeg \
        -disposition:v:0 attached_pic \
        "${file_path%.m4a}_final.m4a" -v quiet -y 2>/dev/null
      
      if [[ -f "${file_path%.m4a}_final.m4a" ]]; then
        mv "${file_path%.m4a}_final.m4a" "$file_path"
      fi
    fi
    
    rm -f "$temp_thumb" "$square_thumb"
  fi
}

process_files() {
  for file in "$MUSIC_DIR/"*.m4a; do
    [ -f "$file" ] || continue

    local artist=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
    
    if [[ -n "$artist" ]]; then
      local clean_artist=$(echo "$artist" | sed -E 's/[,&;].*//')
      local original_filename=$(basename "$file" .m4a)
      echo "Original: $original_filename"

      local sanitized_filename=$(sanitize_filename "$original_filename" "$file")
      sanitized_filename="${sanitized_filename}.m4a"
      local new_file="${file%/*}/$sanitized_filename"

      mv "$file" "$new_file"
      echo "Sanitized filename: $file -> $new_file"

      update_metadata "$new_file" "$clean_artist" "$sanitized_filename"
    else
      echo "Error: Failed to extract artist metadata for $file. Skipping..."
    fi
  done
  
  echo "Sanitization complete!"
}

cleanup() {
  rm -f $COOKIES_FILE
  echo "All tasks completed successfully!"
}

# MAIN
check_dependencies
get_browser_cookies
get_download_type

while true; do
  if ! get_youtube_url; then
    break
  fi
  download_audio "$url"
  echo ""
done

process_files
cleanup
