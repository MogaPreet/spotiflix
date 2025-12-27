import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  Timer? _hideControlsTimer;
  Timer? _positionTimer;

  // State variables
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isFullscreen = true; // Default to fullscreen (landscape)
  double _playbackSpeed = 1.0;

  // Getters
  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get showControls => _showControls;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isFullscreen => _isFullscreen;
  double get playbackSpeed => _playbackSpeed;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Future<void> initialize(String videoUrl) async {
    debugPrint('🎬 Starting video initialization for: $videoUrl');

    // Set landscape mode first
    await setLandscapeMode();

    // Initialize video
    await initializeVideo(videoUrl);

    // Show controls initially
    showControlsWithTimer();
  }

  Future<void> initializeVideo(String videoUrl) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();

      // Dispose of existing controller if any
      if (_controller != null) {
        await _controller!.dispose();
      }

      debugPrint('🎬 Creating video controller...');
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller!.addListener(_videoPlayerListener);

      debugPrint('🎬 Initializing video controller...');
      await _controller!.initialize();

      if (_controller!.value.isInitialized) {
        debugPrint('🎬 Video controller initialized successfully');

        _isInitialized = true;
        _isLoading = false;
        _duration = _controller!.value.duration;

        debugPrint('🎬 Video duration: $_duration');

        // Start position tracking
        _startPositionTimer();

        // Auto play
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_controller != null && _controller!.value.isInitialized) {
            debugPrint('🎬 Auto-playing video...');
            _controller!.play();
          }
        });

        notifyListeners();
      } else {
        throw Exception('Video controller failed to initialize');
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load video: $e';
      notifyListeners();
    }
  }

  void _videoPlayerListener() {
    if (_controller == null || !mounted) return;

    bool shouldNotify = false;

    // Check buffering state
    final bool newBuffering = _controller!.value.isBuffering;
    if (_isBuffering != newBuffering) {
      _isBuffering = newBuffering;
      debugPrint('🔄 Buffering: $newBuffering');
      shouldNotify = true;
    }

    // Check playing state
    final bool newPlaying = _controller!.value.isPlaying;
    if (_isPlaying != newPlaying) {
      _isPlaying = newPlaying;
      debugPrint('▶️ Playing: $newPlaying');
      shouldNotify = true;
    }

    // Check for errors
    if (_controller!.value.hasError && !_hasError) {
      debugPrint('❌ Video error: ${_controller!.value.errorDescription}');
      _hasError = true;
      _errorMessage = 'Playback error: ${_controller!.value.errorDescription}';
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_controller != null && _controller!.value.isInitialized && mounted) {
        final newPosition = _controller!.value.position;
        if (_position != newPosition) {
          _position = newPosition;
          notifyListeners();
        }
      }
    });
  }

  void play() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.play();
      showControlsWithTimer();
      debugPrint('▶️ Playing video');
    }
  }

  void pause() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.pause();
      showControlsWithTimer();
      debugPrint('⏸️ Pausing video');
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(Duration position) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final wasPlaying = _isPlaying;
    _controller!.seekTo(position);

    // Resume playing if it was playing before seek
    if (wasPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_controller != null && _controller!.value.isInitialized) {
          play();
        }
      });
    }
  }

  void skipSeconds(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final newPosition = _position + Duration(seconds: seconds);

    if (newPosition >= Duration.zero && newPosition <= _duration) {
      seekTo(newPosition);
    }
    showControlsWithTimer();
  }

  void showControlsWithTimer() {
    _hideControlsTimer?.cancel();

    if (!_showControls) {
      _showControls = true;
      notifyListeners();
    }

    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _showControls = false;
        notifyListeners();
      }
    });
  }

  void hideControls() {
    if (_showControls) {
      _showControls = false;
      notifyListeners();
    }
  }

  void toggleControls() {
    if (_showControls) {
      hideControls();
    } else {
      showControlsWithTimer();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    if (_isFullscreen) {
      setLandscapeMode();
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.setPlaybackSpeed(speed);
      _playbackSpeed = speed;
      notifyListeners();
      debugPrint('⏩ Playback speed set to: ${speed}x');
    }
  }

  Future<void> setLandscapeMode() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      debugPrint('🔧 Landscape mode set');
    } catch (e) {
      debugPrint('❌ Error setting landscape mode: $e');
    }
  }

  Future<void> restoreOrientationMode() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      debugPrint('🔧 Orientation restored');
    } catch (e) {
      debugPrint('❌ Error restoring orientation: $e');
    }
  }

  bool get mounted => !_disposed;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    debugPrint('🗑️ Disposing VideoPlayerProvider');

    _hideControlsTimer?.cancel();
    _positionTimer?.cancel();

    if (_controller != null) {
      _controller!.removeListener(_videoPlayerListener);
      _controller!.dispose();
    }

    super.dispose();
  }
}
