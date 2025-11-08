# Quick Start - Download Logos

## Prerequisites for Python Script

```bash
pip install requests beautifulsoup4
```

## Run the Download Script

```bash
python scripts/download_logos.py
```

This will:
1. Download all team logos from:
   - https://1000logos.net/soccer/
   - https://1000logos.net/soccer/page/2/
   - Save to: `assets/teams/`

2. Download all league logos from:
   - https://1000logos.net/sports-leagues/
   - https://1000logos.net/sports-leagues/page/2/
   - Save to: `assets/leagues/`

## Expected Output

After running, you'll have:
- `assets/teams/` - Contains all team logos (arsenal.png, barcelona.png, etc.)
- `assets/leagues/` - Contains all league logos (premier_league.png, la_liga.png, etc.)

## Usage in Flutter App

The logos are automatically included in your app via `pubspec.yaml`:
```yaml
assets:
  - assets/teams/
  - assets/leagues/
```

You can load them using:
```dart
Image.asset('assets/teams/arsenal.png')
Image.asset('assets/leagues/premier_league.png')
```

Or use the `LogoLoader` utility:
```dart
final logoPath = LogoLoader.getTeamLogoPath('Arsenal');
if (logoPath != null) {
  Image.asset(logoPath)
}
```

## Notes

- The script includes delays to be respectful to the server
- Some logos may fail to download - check the console output
- File names are sanitized (lowercase, underscores)
- Original file extensions are preserved

