# Logo Download Scripts

Scripts to download football team logos and league logos from 1000logos.net.

## Pages to Download:
- **Team Logos**: 
  - https://1000logos.net/soccer/
  - https://1000logos.net/soccer/page/2/
- **League Logos**:
  - https://1000logos.net/sports-leagues/
  - https://1000logos.net/sports-leagues/page/2/

## Option 1: Python Script (Recommended)

### Prerequisites
```bash
pip install requests beautifulsoup4
```

### Usage
```bash
python scripts/download_logos.py
```

This will:
- Scrape all 4 pages (2 team pages + 2 league pages)
- Download team logos to `assets/teams/`
- Download league logos to `assets/leagues/`
- Save logos with sanitized names as filenames

## Option 2: Dart Script

### Prerequisites
Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.2
  html: ^0.15.4
```

### Usage
```bash
dart pub get
dart scripts/download_logos.dart
```

## Option 3: Manual Download

1. Visit https://1000logos.net/soccer/
2. Visit https://1000logos.net/soccer/page/2/
3. Use browser extension like "Image Downloader" or "Download All Images"
4. Save logos to `assets/teams/` directory

## Notes

- Logos will be saved with sanitized team names (lowercase, underscores)
- File extensions will be preserved (.png, .svg, .jpg, etc.)
- Scripts include delays to be respectful to the server
- Some logos may fail to download - check the output for errors

## Directory Structure

After running:
```
assets/
  teams/
    arsenal.png
    barcelona.png
    manchester_united.png
    ...
  leagues/
    premier_league.png
    la_liga.png
    bundesliga.png
    ...
```

## Output Files

- **Team logos**: Saved to `assets/teams/` with team names as filenames
- **League logos**: Saved to `assets/leagues/` with league names as filenames
- File extensions preserved (.png, .svg, .jpg, .webp)

