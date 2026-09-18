import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import '../../providers/predictions_provider.dart';
import '../../widgets/match_card.dart';
import '../highlights/video_player_screen.dart';
import '../ytPlayer/youtube_player_flutter.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  Timer? _refreshTimer;
  final yt_exp.YoutubeExplode _yt = yt_exp.YoutubeExplode();

  List<yt_exp.Video> _highlightVideos = [];
  bool _isLoadingHighlights = false;
  yt_exp.Video? _selectedVideo;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLive();
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        _refreshLive();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _youtubeController?.dispose();
    _yt.close();
    super.dispose();
  }

  Future<void> _refreshLive() async {
    final provider = Provider.of<PredictionsProvider>(context, listen: false);
    await provider.refreshLiveMatches();

    if (provider.liveMatches.isEmpty && _highlightVideos.isEmpty) {
      _fetchFallbackHighlights();
    }
  }

  Future<void> _fetchFallbackHighlights() async {
    if (_isLoadingHighlights) return;
    setState(() => _isLoadingHighlights = true);

    try {
      final provider = Provider.of<PredictionsProvider>(context, listen: false);
      String query = 'football match highlights today goals';
      if (provider.matches.isNotEmpty) {
        final recentMatch = provider.matches.first;
        query = '${recentMatch.homeTeam} vs ${recentMatch.awayTeam} highlights';
      }

      final searchResults = await _yt.search.search(query);
      final videos = searchResults.take(10).toList();

      if (mounted) {
        setState(() {
          _highlightVideos = videos;
          _isLoadingHighlights = false;
          if (videos.isNotEmpty && _selectedVideo == null) {
            _playHighlight(videos.first);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHighlights = false);
      }
    }
  }

  void _playHighlight(yt_exp.Video video) {
    setState(() {
      _selectedVideo = video;
      _youtubeController?.dispose();
      _youtubeController = YoutubePlayerController(
        initialVideoId: video.id.value,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    });
  }

  void _openFullScreenLandscape(yt_exp.Video video) {
    _youtubeController?.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id.value,
          title: video.title,
          forceLandscape: true,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _youtubeController?.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Live Now',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh live matches',
            onPressed: _refreshLive,
          ),
        ],
      ),
      body: Consumer<PredictionsProvider>(
        builder: (context, provider, child) {
          final liveMatches = provider.liveMatches;

          if (provider.isLoading && liveMatches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (liveMatches.isEmpty) {
            return _buildNoLiveFallbackView(theme, isDark, accent);
          }

          // When live matches are active, display live match cards
          return RefreshIndicator(
            onRefresh: _refreshLive,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: liveMatches.length,
              itemBuilder: (context, index) {
                final match = liveMatches[index];
                return MatchCard(
                  prediction: match,
                  showDate: false,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoLiveFallbackView(
      ThemeData theme, bool isDark, Color accent) {
    return RefreshIndicator(
      onRefresh: _refreshLive,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Informative banner notifying user that no live matches are active
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.tv,
                      size: 16,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'NO LIVE MATCHES RIGHT NOW',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enjoying auto-played highlights of recent matches while waiting for live games to start.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Auto-play Video Player Card
          if (_youtubeController != null && _selectedVideo != null) ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Embedded video player
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: accent,
                        progressColors: ProgressBarColors(
                          playedColor: accent,
                          handleColor: accent,
                        ),
                      ),
                    ),

                    // Controls & Title Bar
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedVideo!.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVideo!.author,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),

                              // Full screen landscape button
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _openFullScreenLandscape(_selectedVideo!),
                                icon: const FaIcon(
                                  FontAwesomeIcons.expand,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Full Screen',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_isLoadingHighlights) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading match highlights...',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Playlist of other match highlights
          if (_highlightVideos.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PREVIOUS MATCH HIGHLIGHTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${_highlightVideos.length} matches',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _highlightVideos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final vid = _highlightVideos[index];
                final isPlaying = _selectedVideo?.id.value == vid.id.value;

                return GestureDetector(
                  onTap: () => _playHighlight(vid),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isPlaying
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF162032))
                          : (isPlaying
                              ? Colors.white
                              : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Thumbnail with play icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                vid.thumbnails.mediumResUrl,
                                width: 90,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 56,
                                  color: Colors.black26,
                                  child: const Icon(Icons.play_circle_fill),
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? accent
                                      : Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: FaIcon(
                                    isPlaying
                                        ? FontAwesomeIcons.volumeHigh
                                        : FontAwesomeIcons.play,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Channel
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vid.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isPlaying
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: isPlaying ? accent : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vid.author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Direct landscape button
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowUpRightFromSquare,
                            size: 14,
                          ),
                          tooltip: 'Play full screen landscape',
                          onPressed: () => _openFullScreenLandscape(vid),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
