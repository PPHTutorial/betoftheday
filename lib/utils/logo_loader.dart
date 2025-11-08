import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Utility class to load team and league logos from assets
class LogoLoader {
  /// Get team logo path from team name with fuzzy matching
  static String? getTeamLogoPath(String teamName) {
    // Try multiple variations of the name
    final variations = generateNameVariations(teamName);

    // Try different extensions in order
    final extensions = ['png', 'svg', 'jpg', 'jpeg', 'webp'];

    for (final variation in variations) {
      for (final ext in extensions) {
        final path = 'assets/teams/$variation.$ext';
        // Try to load the asset - if it exists, return it
        // Note: We can't check if asset exists at runtime easily,
        // so we'll try all variations and let Image.asset handle errors
        return path; // Return first variation, error handling in widget
      }
    }
    return null;
  }

  /// Generate multiple name variations for fuzzy matching
  static List<String> generateNameVariations(String name) {
    final variations = <String>{};

    // Original sanitized
    variations.add(_sanitizeName(name));

    // Remove common prefixes/suffixes
    final cleaned = name
        .replaceAll(
            RegExp(r'\b(FC|CF|AC|SC|United|City|FC|CF)\b',
                caseSensitive: false),
            '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isNotEmpty && cleaned != name) {
      variations.add(_sanitizeName(cleaned));
    }

    // Try with underscores instead of spaces
    final withUnderscores = name.replaceAll(' ', '_').toLowerCase();
    variations.add(_sanitizeName(withUnderscores));

    // Try without common words
    final withoutCommon = name
        .replaceAll(
            RegExp(r'\b(the|of|and|club|team|football|soccer)\b',
                caseSensitive: false),
            '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (withoutCommon.isNotEmpty) {
      variations.add(_sanitizeName(withoutCommon));
    }

    // Try acronym version (e.g., "AC Milan" -> "acmilan")
    final acronym = name
        .split(RegExp(r'\s+'))
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toLowerCase();
    if (acronym.length >= 2) {
      variations.add(acronym);
    }

    // Try first word only (e.g., "AC Milan" -> "ac")
    final firstWord = name.split(RegExp(r'\s+')).first.toLowerCase();
    if (firstWord.length >= 2) {
      variations.add(_sanitizeName(firstWord));
    }

    // Try last word only (e.g., "AC Milan" -> "milan")
    final words = name.split(RegExp(r'\s+'));
    if (words.length > 1) {
      final lastWord = words.last.toLowerCase();
      if (lastWord.length >= 2) {
        variations.add(_sanitizeName(lastWord));
      }
    }

    return variations.toList();
  }

  /// Get league logo path from league name with fuzzy matching
  static String? getLeagueLogoPath(String leagueName) {
    // Try multiple variations of the name
    final variations = generateNameVariations(leagueName);

    // Try different extensions in order
    final extensions = ['png', 'svg', 'jpg', 'jpeg', 'webp'];

    for (final variation in variations) {
      for (final ext in extensions) {
        final path = 'assets/leagues/$variation.$ext';
        return path; // Return first variation, error handling in widget
      }
    }
    return null;
  }

  /// Widget to display a team logo with fuzzy matching
  static Widget teamLogo(
    String teamName, {
    double? size,
    BoxFit? fit,
    Color? placeholderColor,
  }) {
    return _LogoWidget(
      name: teamName,
      isTeam: true,
      size: size,
      fit: fit,
      placeholderColor: placeholderColor,
    );
  }

  /// Widget to display a league logo with fuzzy matching
  static Widget leagueLogo(
    String leagueName, {
    double? size,
    BoxFit? fit,
    Color? placeholderColor,
  }) {
    return _LogoWidget(
      name: leagueName,
      isTeam: false,
      size: size,
      fit: fit,
      placeholderColor: placeholderColor,
    );
  }

  /// Build placeholder widget when logo is not found
  static Widget _buildPlaceholder(
    IconData icon, {
    double? size,
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: (size ?? 40) * 0.6,
        color: color ?? Colors.grey,
      ),
    );
  }

  /// Sanitize name to match filename format (same as Python script)
  static String _sanitizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Try to find team logo by partial name match
  static String? findTeamLogoByPartial(String teamName) {
    // This is a helper that could be enhanced with fuzzy matching
    // For now, just try the sanitized name
    return getTeamLogoPath(teamName);
  }

  /// Try to find league logo by partial name match
  static String? findLeagueLogoByPartial(String leagueName) {
    // This is a helper that could be enhanced with fuzzy matching
    // For now, just try the sanitized name
    return getLeagueLogoPath(leagueName);
  }
}

/// Widget that tries multiple logo variations
class _LogoWidget extends StatefulWidget {
  final String name;
  final bool isTeam;
  final double? size;
  final BoxFit? fit;
  final Color? placeholderColor;

  const _LogoWidget({
    required this.name,
    required this.isTeam,
    this.size,
    this.fit,
    this.placeholderColor,
  });

  @override
  State<_LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<_LogoWidget> {
  String? _foundPath;

  @override
  void initState() {
    super.initState();
    _tryLoadLogo();
  }

  Future<void> _tryLoadLogo() async {
    final variations = LogoLoader.generateNameVariations(widget.name);
    final extensions = ['png', 'svg', 'jpg', 'jpeg', 'webp'];
    final basePath = widget.isTeam ? 'assets/teams/' : 'assets/leagues/';

    for (final variation in variations) {
      for (final ext in extensions) {
        final path = '$basePath$variation.$ext';

        try {
          // Try to load the asset
          await rootBundle.load(path);
          // If successful, use this path
          if (mounted) {
            setState(() {
              _foundPath = path;
            });
            return;
          }
        } catch (e) {
          // Asset doesn't exist, try next
          continue;
        }
      }
    }

    // No logo found
    if (mounted) {
      setState(() {
        _foundPath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_foundPath == null) {
      return LogoLoader._buildPlaceholder(
        widget.isTeam ? Icons.sports_soccer : Icons.emoji_events,
        size: widget.size ?? 40,
        color: widget.placeholderColor,
      );
    }

    if (_foundPath!.endsWith('.svg')) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: SvgPicture.asset(
          _foundPath!,
          fit: widget.fit ?? BoxFit.contain,
          width: widget.size,
          height: widget.size,
          placeholderBuilder: (context) => LogoLoader._buildPlaceholder(
            widget.isTeam ? Icons.sports_soccer : Icons.emoji_events,
            size: widget.size ?? 40,
            color: widget.placeholderColor,
          ),
        ),
      );
    }

    return Image.asset(
      _foundPath!,
      width: widget.size,
      height: widget.size,
      fit: widget.fit ?? BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          LogoLoader._buildPlaceholder(
        widget.isTeam ? Icons.sports_soccer : Icons.emoji_events,
        size: widget.size ?? 40,
        color: widget.placeholderColor,
      ),
    );
  }
}
