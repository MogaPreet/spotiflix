import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_player_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String movieTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.movieTitle,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late AnimationController _playPauseAnimationController;
  late AnimationController _buttonPressAnimationController;
  late Animation<double> _controlsOpacity;
  late Animation<double> _playPauseScale;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonPressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _controlsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _playPauseScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playPauseAnimationController,
      curve: Curves.elasticOut,
    ));

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _buttonPressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _playPauseAnimationController.dispose();
    _buttonPressAnimationController.dispose();
    super.dispose();
  }

  void _handlePlayPauseAnimation() {
    _playPauseAnimationController.forward().then((_) {
      _playPauseAnimationController.reverse();
    });
  }

  void _handleButtonPress() {
    _buttonPressAnimationController.forward().then((_) {
      _buttonPressAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VideoPlayerProvider()..initialize(widget.videoUrl),
      child: Consumer<VideoPlayerProvider>(
        builder: (context, provider, child) {
          // Animate controls visibility
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.showControls &&
                !_controlsAnimationController.isCompleted) {
              _controlsAnimationController.forward();
            } else if (!provider.showControls &&
                _controlsAnimationController.isCompleted) {
              _controlsAnimationController.reverse();
            }
          });

          return WillPopScope(
            onWillPop: () async {
              provider.restoreOrientationMode();
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(VideoPlayerProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingScreen();
    }

    if (provider.hasError) {
      return _buildErrorScreen(provider);
    }

    if (!provider.isInitialized || provider.controller == null) {
      return _buildLoadingScreen();
    }

    return _buildVideoPlayer(provider);
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFE50914), // Netflix red
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(VideoPlayerProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red[900]!.withOpacity(0.1),
            Colors.black,
            Colors.red[900]!.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.8),
                      Colors.red.withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Playback Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  provider.errorMessage ?? 'Unable to play this video',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEnhancedButton(
                    onPressed: () => provider.initialize(widget.videoUrl),
                    icon: Icons.refresh_rounded,
                    label: 'Retry',
                    isPrimary: true,
                  ),
                  const SizedBox(width: 24),
                  _buildEnhancedButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back_rounded,
                    label: 'Go Back',
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              )
            : null,
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerProvider provider) {
    return GestureDetector(
      onTap: () => provider.toggleControls(),
      child: Stack(
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: provider.controller!.value.aspectRatio,
              child: VideoPlayer(provider.controller!),
            ),
          ),

          // Minimal buffering indicator - Netflix style
          if (provider.isBuffering)
            Center(
              child: SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFE50914), // Netflix red
                  ),
                ),
              ),
            ),

          // Controls overlay
          if (provider.showControls)
            AnimatedBuilder(
              animation: _controlsAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _controlsOpacity.value,
                  child: _buildControls(provider),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControls(VideoPlayerProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.85),
          ],
          stops: const [0.0, 0.15, 0.5, 0.75, 1.0],
        ),
      ),
      child: Column(
        children: [
          _buildTopControls(provider),
          Expanded(child: _buildCenterControls(provider)),
          _buildBottomControls(provider),
        ],
      ),
    );
  }

  Widget _buildTopControls(VideoPlayerProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 24,
              color: Colors.white,
              onPressed: () {
                provider.restoreOrientationMode();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                widget.movieTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Cast button
            IconButton(
              icon: const Icon(Icons.cast_rounded),
              iconSize: 24,
              color: Colors.white,
              onPressed: () {
                // Cast functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls(VideoPlayerProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedBuilder(
          animation: _buttonScale,
          child: _buildSkipButton(
            icon: Icons.replay_10_rounded,
            onPressed: () {
              _handleButtonPress();
              provider.skipSeconds(-10);
            },
          ),
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScale.value,
              child: child,
            );
          },
        ),
        AnimatedBuilder(
          animation: _playPauseScale,
          child: _buildPlayPauseButton(provider),
          builder: (context, child) {
            return Transform.scale(
              scale: _playPauseScale.value,
              child: child,
            );
          },
        ),
        AnimatedBuilder(
          animation: _buttonScale,
          child: _buildSkipButton(
            icon: Icons.forward_10_rounded,
            onPressed: () {
              _handleButtonPress();
              provider.skipSeconds(10);
            },
          ),
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScale.value,
              child: child,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(VideoPlayerProvider provider) {
    return GestureDetector(
      onTap: () {
        _handlePlayPauseAnimation();
        provider.togglePlayPause();
      },
      child: Icon(
        provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 72,
      ),
    );
  }

  Widget _buildSkipButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        icon,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Netflix-style progress bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFFE50914), // Netflix red
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: const Color(0xFFE50914),
                overlayColor: const Color(0xFFE50914).withOpacity(0.2),
              ),
              child: Slider(
                value: provider.position.inMilliseconds.toDouble(),
                min: 0,
                max: provider.duration.inMilliseconds
                    .toDouble()
                    .clamp(1, double.infinity),
                onChanged: (value) {
                  provider.seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            const SizedBox(height: 8),
            // Bottom row with time and controls
            Row(
              children: [
                // Time display
                Text(
                  '${provider.formatDuration(provider.position)} / ${provider.formatDuration(provider.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                // Playback speed
                IconButton(
                  icon: const Text(
                    '1x',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    // Show playback speed options
                    _showPlaybackSpeedDialog(provider);
                  },
                ),
                // Episodes/Subtitles
                IconButton(
                  icon: const Icon(Icons.subtitles_outlined),
                  iconSize: 24,
                  color: Colors.white,
                  onPressed: () {
                    // Show subtitles options
                  },
                ),
                // Fullscreen toggle
                IconButton(
                  icon: Icon(
                    provider.isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                  ),
                  iconSize: 28,
                  color: Colors.white,
                  onPressed: () {
                    provider.toggleFullscreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaybackSpeedDialog(VideoPlayerProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Playback Speed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              0.5,
              0.75,
              1.0,
              1.25,
              1.5,
              2.0,
            ].map((speed) => ListTile(
                  onTap: () {
                    provider.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                  title: Text(
                    speed == 1.0 ? 'Normal' : '${speed}x',
                    style: TextStyle(
                      color: provider.playbackSpeed == speed
                          ? const Color(0xFFE50914)
                          : Colors.white,
                      fontWeight: provider.playbackSpeed == speed
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: provider.playbackSpeed == speed
                      ? const Icon(Icons.check, color: Color(0xFFE50914))
                      : null,
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
