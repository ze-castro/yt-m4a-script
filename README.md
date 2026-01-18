# Music Downloader for MacOS

<img src="/icon.png" alt="icon" width="120" height="120">

This command line tool downloads YouTube songs/playlists/albums as high-quality M4A files with embedded metadata and square album art. It also cleans up filenames by removing artist names and unnecessary words like "(Official Video)" or "(Audio)".

## 🙋 Why not MP3?

M4A (AAC) is a more modern audio format than MP3, offering better sound quality at lower bitrates. Also is the native format for Youtube Music and other streaming services. It means that you can get the same audio quality as MP3 but with smaller file sizes. This is especially useful for music, where you want to maintain quality while saving space.

## 🎵 Features

✅ **Downloads high-quality (+256 kbps) M4A files**  
✅ **Automatically fetches metadata** 
✅ **Original album track order** 
✅ **Embeds square album art**  
✅ **Cleans up filenames**  
✅ **Supports playlists and albums**  
✅ **Automatically fetches login cookies**
✅ **Avoids rate limiting**

## ⚠️ Disclaimer

This script is intended for **personal use only**. Downloading copyrighted material **without permission** may violate copyright laws. Ensure you have the right to download and use the content before proceeding.

This script is provided "as is" **without warranty** of any kind. I am **not responsible** for any damages or **legal issues** that may arise from its use.

## 📌 Requirements

This script is only available for **MacOS**.
I use `brew` to download `deno`, `ffmpeg` and `yt-dlp`, feel free to use another **package manager**.

1. Install **deno**:

   ```zsh
   brew install deno
   ```

2. Install **ffmpeg**:

   ```zsh
   brew install ffmpeg
   ```

3. Install **yt-dlp**:

   ```sh
   brew install yt-dlp
   ```

4. Ensure **Firefox**, **Chrome** or **Safari** is installed (for automatic YouTube login cookies).

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
5. The M4A files will be saved in `~/Downloads/music/` when downloading unformatted audio.
   If you download a playlist or album, it will be saved in `~/Downloads/album_name/`.

**NOTE**: I recommend downloading from `music.youtube.com` as it often has the correct metadata and album art.

## 🎚 Changing Audio Quality

The script downloads the **best available** audio quality by default. To specify a different quality, modify the `yt-dlp` command:

- **For highest quality (default):**

  ```zsh
  MUSIC_QUALITY=0 # +256 kbps
  ```

- **For medium quality (e.g., 128kbps):**

  ```zsh
  MUSIC_QUALITY=5 # 128 kbps
  ```

  I do not recommend using lower quality than `128 kbps` as it may result in poor audio quality.

## 🚨 Known Errors

### 1. Signature Extraction Failure

```zsh
WARNING: [youtube] PIuAFrLeXfY: Signature extraction failed: Some formats may be missing.
```

*Solution*: Update `yt-dlp` to the latest version with `brew upgrade yt-dlp`.

## 👾 Extra

### To double click to open the script

1. Right-click the script and select **Rename**.
2. Change the file extension from `.zsh` to `.command`.

### To add an icon to the .command file

1. Right-click the `.command` file and select **Get Info**.
2. Drag and drop the .icns image into the top left corner of the **Get Info** window.
3. Close the **Get Info** window.
4. Now, you can double-click the `.command` file to run the script.

Enjoy your music! 🎶
