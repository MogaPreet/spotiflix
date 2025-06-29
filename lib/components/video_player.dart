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
  late Animation<double> _controlsOpacity;
  late Animation<double> _playPauseScale;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _controlsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _playPauseScale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _playPauseAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _playPauseAnimationController.dispose();
    super.dispose();
  }

  void _handlePlayPauseAnimation() {
    _playPauseAnimationController.forward().then((_) {
      _playPauseAnimationController.reverse();
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
            if (provider.showControls && !_controlsAnimationController.isCompleted) {
              _controlsAnimationController.forward();
            } else if (!provider.showControls && _controlsAnimationController.isCompleted) {
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loading ${widget.movieTitle}...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please wait while we prepare your video',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(VideoPlayerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Video Playback Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Unable to play this video',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    provider.initialize(widget.videoUrl);
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text('Go Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          
          // Buffering indicator
          if (provider.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Buffering...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
            Colors.black.withOpacity(0.8),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.25, 0.75, 1.0],
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
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                provider.restoreOrientationMode();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.movieTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () => provider.skipSeconds(-10),
          size: 48,
        ),
        GestureDetector(
          onTap: () {
            _handlePlayPauseAnimation();
            provider.togglePlayPause();
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Icon(
              provider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () => provider.skipSeconds(10),
          size: 48,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress bar
            VideoProgressIndicator(
              provider.controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Colors.grey.withOpacity(0.5),
                backgroundColor: Colors.grey.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 20),
            // Time display
            Row(
              children: [
                Text(
                  provider.formatDuration(provider.position),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  '/',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  provider.formatDuration(provider.duration),
                  style: TextStyle(color: Colors.grey[300], fontSize: 16),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}