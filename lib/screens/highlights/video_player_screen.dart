import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ytPlayer/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final bool forceLandscape;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.forceLandscape = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _isLandscape = widget.forceLandscape;

    if (widget.forceLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLandscape ? Icons.screen_lock_portrait_rounded : Icons.screen_lock_landscape_rounded,
              color: Colors.white,
            ),
            tooltip: _isLandscape ? 'Switch to Portrait' : 'Switch to Full Screen Landscape',
            onPressed: _toggleOrientation,
          ),
        ],
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: theme.colorScheme.primary,
          progressColors: ProgressBarColors(
            playedColor: theme.colorScheme.primary,
            handleColor: theme.colorScheme.primary,
          ),
          onReady: () {
            // Player is ready
          },
        ),
      ),
    );
  }
}
