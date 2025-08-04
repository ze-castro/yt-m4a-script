#!/bin/zsh

# CONFIGURATION
## DIRECTORIES
### Main directory for downloads
MAIN_DIR="$HOME/Downloads"
### Directory for music files
MUSIC_DIR="$MAIN_DIR/music"
### Location to store cookies
COOKIES_FILE="$MAIN_DIR/youtube.cookies.txt"

## BROWSER
### Your preferred browser (e.g., chrome, firefox, safari)
BROWSER="safari"

## Music Quality
### (0 = best, 10 = worst)
MUSIC_QUALITY=0

## SANITIZATION
### Global sanitization state
SANITIZATION_MODE=""
### Sanitization modes
readonly SANITIZATION_HARD="hard"
readonly SANITIZATION_SOFT="soft"

###############################################################################

# LOGGING
log_info() {
  echo "[INFO] $*" >&2
}
log_error() {
  echo "[ERROR] $*" >&2
}
log_warning() {
  echo "[WARNING] $*" >&2
}
log_success() {
  echo "[SUCCESS] $*" >&2
}

# ERROR HANDLING
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

###############################################################################

# DEPENDENCIES
## Default message for missing dependencies
check_command() {
    local cmd=$1
    local install_msg=$2
    
    if ! command -v "$cmd" &> /dev/null; then
        error_exit "$cmd is not installed! $install_msg"
    fi
}
# Check if yt-dlp and ffmpeg are installed
check_dependencies() {
  check_command "yt-dlp" "Install it from: https://github.com/yt-dlp/yt-dlp"
  check_command "ffmpeg" "Install it from: https://ffmpeg.org/download.html"
}

###############################################################################

# COOKIE HANDLING
## Get cookies from the specified browser
get_browser_cookies() {
  log_info "Getting cookies from $BROWSER browser..."
  yt-dlp --cookies-from-browser $BROWSER --cookies "$COOKIES_FILE" --flat-playlist --quiet --no-warnings "https://www.youtube.com"

  if [ ! -f $COOKIES_FILE ]; then
    error_exit "Failed to retrieve cookies from $BROWSER. Please ensure you have the correct browser name configured and are logged in to YouTube."
  fi

  log_success "Successfully retrieved cookies from $BROWSER"
}

###############################################################################

# DOWNLOAD HANDLING
## Get the download type (unformatted audio or playlist/album)
get_download_type() {
  while [[ "$SANITIZATION_MODE" != "$SANITIZATION_HARD" && "$SANITIZATION_MODE" != "$SANITIZATION_SOFT" ]]; do
    echo -n "Are you downloading unformatted audio? (y/n): "
    read download_type

    case $download_type in
      (y|Y|yes|Yes)
        SANITIZATION_MODE=$SANITIZATION_HARD
        log_info "Downloading Unformatted Audio"
        ;;
      (n|N|no|No)
        SANITIZATION_MODE=$SANITIZATION_SOFT
        log_info "Downloading Albums or Playlists"
        ;;
      (*)
        log_warning "Invalid choice. Try again."
        ;;
    esac
  done
}

###############################################################################

# URL HANDLING
## Get the YouTube URL from the user
get_youtube_url() {
  while true; do
      echo -n "Enter YouTube Playlist or Song URL (or 'q' to quit): "
      read url
      
      if [[ "$url" == "q" ]]; then
          return 1
      fi
      
      if [[ -n "$url" ]]; then
          log_info "Downloading from URL: $url"
          return 0
      fi
      
      echo "Please enter a valid URL or 'q' to quit."
  done
}

## Download audio from the provided URL
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
}

###############################################################################

# FILE HANDLING
## Sanitize filenames
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

## Update metadata for the downloaded file
update_metadata() {
  local file_path=$1
  local clean_artist=$2
  local sanitized_title=${3%.m4a}
  local album=$4
  local year=$5

  local track_number=""
  local clean_title=$(echo "$sanitized_title" | sed -E 's/^[0-9]{1,2}\. //g')
  if [[ "$sanitized_title" =~ ^([0-9]{1,2})\. ]]; then
    local track_number="${match[1]}"
  fi

  ffmpeg -i "$file_path" \
    -metadata artist="$clean_artist" \
    -metadata title="$clean_title" \
    -metadata track="$track_number" \
    -metadata album="$album" \
    -metadata date="$year" \
    -codec copy "${file_path%.m4a}_temp.m4a"
  
  mv "${file_path%.m4a}_temp.m4a" "$file_path"

  process_thumbnail "$file_path"

  log_success "Updated metadata for: $file_path"
}

## Process thumbnail and embed it into the audio file
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
  log_success "Processed thumbnail for: $file_path"
}

## Process files after downloading
### This function renames files, updates metadata, and organizes them into albums if applicable
process_files() {
  local year=""
  for file in "$MUSIC_DIR/"*.m4a; do
      [ -f "$file" ] || continue
      year=$(ffprobe -v quiet -show_entries format_tags=date -of default=noprint_wrappers=1:nokey=1 "$file")
      break
  done
  
  local album=""
  for file in "$MUSIC_DIR/"*.m4a; do
    [ -f "$file" ] || continue

    local artist=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
    album=$(ffprobe -v quiet -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")
    
    if [[ -n "$artist" ]]; then
      local clean_artist=$(echo "$artist" | sed -E 's/[,&;].*//')
      local original_filename=$(basename "$file" .m4a)

      local sanitized_filename=$(sanitize_filename "$original_filename" "$file")
      sanitized_filename="${sanitized_filename}.m4a"
      local new_file="${file%/*}/$sanitized_filename"

      mv "$file" "$new_file"
      log_info "Sanitized filename: $file -> $new_file"

      update_metadata "$new_file" "$clean_artist" "$sanitized_filename" "$album" "$year"
    else
      log_error "Failed to extract artist metadata for $file. Skipping..."
    fi
  done

  if [[ -n "$album" && "$SANITIZATION_MODE" == "soft" ]]; then
    mkdir -p "$MAIN_DIR/$album"
    mv "$MUSIC_DIR"/* "$MAIN_DIR/$album/"
    rm -r "$MUSIC_DIR"
  fi
}

###############################################################################

# CLEANUP
## Remove cookies after processing
cleanup() {
  rm -f $COOKIES_FILE
  log_success "All tasks completed successfully!"
}

###############################################################################

# MAIN
## Run the script
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
