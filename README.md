# YouTube Downloader

<img src="/icon.png" alt="icon" width="150" height="150">

This script downloads YouTube songs/playlists as high-quality M4A files with embedded metadata and album art. It also cleans up filenames by removing artist names, "FT", and unnecessary words like "(Official Video)" or "(Audio)".

## 🙋 Why not MP3?

M4A (AAC) is a more modern audio format than MP3, offering better sound quality at lower bitrates. It means that you can get the same audio quality as MP3 but with smaller file sizes. This is especially useful for music, where you want to maintain quality while saving space.

## 🎵 Features

✅ **Downloads high-quality M4A (AAC)**  
✅ **Embeds album art & metadata**  
✅ **Cleans filenames & metadata**  
✅ **Removes artist name & extra tags**  
✅ **Automatically fetches login cookies**

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
3. Ensure **Firefox**, **Chrome** or **Safari** is installed (for automatic YouTube login cookies).

## 🚀 How to Use

1. Check your browser! If you use Google Chrome change `BROWSER` to `chrome`:

   ```zsh
   BROWSER="chrome" # Change this to your preferred browser.
   ```

   Supported browsers are: brave, chrome, chromium, edge, firefox, opera, safari, vivaldi, whale.

2. Save the script as `yt-m4a.zsh` and give it execute permissions (you can also give 'Full Disk Access' to the terminal app if you want to run it from anywhere):
   ```zsh
   chmod +x yt-m4a.zsh
   ```
3. Run the script:
   ```zsh
   ./yt-m4a.zsh
   ```
4. When prompted, enter the **YouTube video or playlist URL** when prompted.
5. The M4A files will be saved in `~/Downloads/music/`.

**NOTE**: I recommend donwloading from `music.youtube.com` as it often has the correct metadata and album art.

## 👾 Extra (MacOS only)

### To double click to open the script:

1. Right-click the script and select **Rename**.
2. Change the file extension from `.zsh` to `.command`.

### To add an icon to the .command file:

1. Right-click the `.command` file and select **Get Info**.
2. Drag and drop the .icns image into the top left corner of the **Get Info** window.
3. Close the **Get Info** window.
4. Now, you can double-click the `.command` file to run the script.

## 🎚 Changing Audio Quality

The script downloads the **best available** audio quality by default. To specify a different quality, modify the `yt-dlp` command:

- **For highest quality (default):**
  ```zsh
  yt-dlp -x --audio-format aac --audio-quality 0
  ```
- **For medium quality (e.g., 128kbps):**
  ```zsh
  yt-dlp -x --audio-format aac --audio-quality 5
  ```
- **For lower quality (e.g., 64kbps):**
  ```zsh
  yt-dlp -x --audio-format aac --audio-quality 9
  ```

Enjoy your music! 🎶
