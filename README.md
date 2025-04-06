# YouTube MP3 Downloader

<img src="/icon.png" alt="icon" width="150" height="150">

This script downloads YouTube songs/playlists as high-quality MP3 files with embedded metadata and album art. It also cleans up filenames by removing artist names, "FT", and unnecessary words like "(Official Video)" or "(Audio)".

## 📌 Requirements

1. Install **yt-dlp**:
   ```sh
   brew install yt-dlp  # macOS
   sudo apt install yt-dlp  # Linux (Debian/Ubuntu)
   choco install yt-dlp  # Windows (via Chocolatey)
   ```
2. Install **ffmpeg**:
   ```zsh
   brew install ffmpeg  # macOS
   sudo apt install ffmpeg  # Linux
   choco install ffmpeg  # Windows
   ```
3. Ensure **Firefox** or **Chrome** is installed (for automatic YouTube login cookies).

## 🚀 How to Use

1. Save the script as `yt-mp3.zsh` and give it execute permissions:
   ```zsh
   chmod +x yt-mp3.zsh
   ```
2. Run the script:
   ```zsh
   ./yt-mp3.zsh
   ```
3. Enter the **YouTube video or playlist URL** when prompted.
4. The MP3 files will be saved in `~/Downloads/music/`.

## 👾 Extra

### To double click to open the script:

1. Right-click the script and select **Rename**.
2. Change the file extension from `.zsh` to `.command`.

### To add an icon to the command file:

1. Right-click the `.command` file and select **Get Info**.
2. Drag and drop the .icns image into the top left corner of the **Get Info** window.
3. Close the **Get Info** window.
4. Now, you can double-click the `.command` file to run the script.

## 🔄 Using Chrome Instead of Firefox

By default, the script uses Firefox cookies. To use Chrome instead:

```sh
BROWSER="chrome" ./yt-mp3.zsh
```

## 🎚 Changing Audio Quality

The script downloads the **best available** audio quality by default. To specify a different quality, modify the `yt-dlp` command inside `yt-mp3.zsh`:

- **For highest quality (default):**
  ```zsh
  yt-dlp -x --audio-format mp3 --audio-quality 0
  ```
- **For medium quality (e.g., 128kbps):**
  ```zsh
  yt-dlp -x --audio-format mp3 --audio-quality 5
  ```
- **For lower quality (e.g., 64kbps):**
  ```zsh
  yt-dlp -x --audio-format mp3 --audio-quality 9
  ```

## 🎵 Features

✔ **Downloads high-quality MP3**  
✔ **Embeds album art & metadata**  
✔ **Cleans filenames & metadata**  
✔ **Removes artist name & extra tags**  
✔ **Automatically fetches login cookies**

Enjoy your music! 🎶
