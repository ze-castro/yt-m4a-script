## v1.0.2 - 16.04.2026

### Overview
This disables the sleep intervals to speed up downloads, but may lead to rate limiting by YouTube.

### Features
- Speed up downloads by disabling sleep intervals.

### Notes
- If you encounter rate limiting, enable the sleep intervals by removing the `--extractor-arg "youtube:playback_wait=0"` line from the script.

----------------------------------------------------------------------

## v1.0.1 - 24.01.2026

### Overview
This release fixes YouTube player new restriction.

### Features
- Replaced player type.

### Notes
- Stay updated. Youtube can change its restrictions anytime.

----------------------------------------------------------------------

## v1.0.0 - 18.01.2026

### Overview
Initial public release of the script. Provides the core functionality to download and insert metadata into songs.

### Features
- Downloads music from YouTube Music
- Adds metadata such as artist and album
- Keeps albums in the original order
- Includes album art

### Limitations
- The artist is always the first artist in the artist metadata field.
- Only supports zsh (Z shell).

### Notes
- This is the baseline release. All future changes will be documented relative to this version.