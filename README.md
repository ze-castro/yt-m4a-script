# YouTube MP3 Downloader

This script downloads YouTube songs/playlists as high-quality MP3 files with embedded metadata and album art. It also cleans up filenames by removing artist names, "FT", and unnecessary words like "(Official Video)" or "(Audio)".

## 📌 Requirements

1. Install **yt-dlp**:
   ```sh
   brew install yt-dlp  # macOS
   sudo apt install yt-dlp  # Linux (Debian/Ubuntu)
   choco install yt-dlp  # Windows (via Chocolatey)
   ```
2. Install **ffmpeg**:
   ```sh
   brew install ffmpeg  # macOS
   sudo apt install ffmpeg  # Linux
   choco install ffmpeg  # Windows
   ```
3. Ensure **Firefox** or **Chrome** is installed (for automatic YouTube login cookies).

## 🚀 How to Use

1. Save the script as `yt-mp3.sh` and give it execute permissions:
   ```sh
   chmod +x yt-mp3.sh
   ```
2. Run the script:
   ```sh
   ./yt-mp3.sh
   ```
3. Enter the **YouTube video or playlist URL** when prompted.
4. The MP3 files will be saved in `~/Downloads/music/`.

## 🔄 Using Chrome Instead of Firefox

By default, the script uses Firefox cookies. To use Chrome instead:
   ```sh
   BROWSER="chrome" ./yt-mp3.sh
   ```

## 🎚 Changing Audio Quality

The script downloads the **best available** audio quality by default. To specify a different quality, modify the `yt-dlp` command inside `yt-mp3.sh`:

- **For highest quality (default):**
  ```sh
  yt-dlp -x --audio-format mp3 --audio-quality 0
  ```
- **For medium quality (e.g., 128kbps):**
  ```sh
  yt-dlp -x --audio-format mp3 --audio-quality 5
  ```
- **For lower quality (e.g., 64kbps):**
  ```sh
  yt-dlp -x --audio-format mp3 --audio-quality 9
  ```

## 🎵 Features

✔ **Downloads high-quality MP3**  
✔ **Embeds album art & metadata**  
✔ **Cleans filenames & metadata**  
✔ **Removes artist name & extra tags**  
✔ **Automatically fetches login cookies**

Enjoy your music! 🎶