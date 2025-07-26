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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: Center(
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
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Loading ${widget.movieTitle}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Text(
                'Preparing your cinematic experience',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
        gradient: isPrimary ? LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ) : null,
        border: isPrimary ? null : Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
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
          
          // Buffering indicator
          if (provider.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Buffering...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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
            Colors.black.withOpacity(0.9),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
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
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildGlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () {
                provider.restoreOrientationMode();
                Navigator.pop(context);
              },
              size: 20,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                widget.movieTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
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
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: -5,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: Icon(
          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 56,
        ),
      ),
    );
  }

  Widget _buildSkipButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return _buildGlassButton(
      icon: icon,
      onPressed: onPressed,
      size: 32,
      padding: 20,
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    double padding = 16,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -3,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerProvider provider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress bar container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: VideoProgressIndicator(
                provider.controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Colors.white.withOpacity(0.3),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Time display and controls
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    provider.formatDuration(provider.position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '/',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    provider.formatDuration(provider.duration),
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
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
}