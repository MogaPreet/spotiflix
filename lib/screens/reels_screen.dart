import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie_model.dart';
import '../services/api/movie_service.dart';
import 'dart:async';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with AutomaticKeepAliveClientMixin {
  final MovieService _movieService = MovieService();
  final PageController _pageController = PageController();
  
  List<Movie> _moviesWithTrailers = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  YoutubePlayerController? _controller;
  Timer? _autoplayTimer;
  bool _audioMuted = false;
  bool _isFullScreen = true; // Default to true for immersive experience
  bool _uiVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMoviesWithTrailers();
    
    // Set system UI for immersive experience when tab is first shown
    // _setImmersiveMode();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure immersive mode is set whenever this tab becomes active
    _setImmersiveMode();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _autoplayTimer?.cancel();
    _pageController.dispose();
    // Restore UI when tab is disposed
    _restoreUI();
    super.dispose();
  }
  
  // Set immersive mode for full-screen experience
  void _setImmersiveMode() {
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  // Restore normal UI mode
  void _restoreUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  
  // Toggle between full-screen and normal mode
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        _setImmersiveMode();
      } else {
        _restoreUI();
      }
    });
  }
  
  // Toggle UI visibility with auto-hide
  void _toggleUI() {
    setState(() {
      _uiVisible = !_uiVisible;
    });
    
    // Auto-hide UI after 3 seconds if visible
    if (_uiVisible) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _uiVisible = false;
          });
        }
      });
    }
  }

  Future<void> _loadMoviesWithTrailers() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get all movies
      final allMovies = await _movieService.getAllMovies();
      
      // Filter to only those with trailers
      final moviesWithTrailers = allMovies
          .where((movie) => 
              movie.trailerUrl.isNotEmpty && 
              YoutubePlayer.convertUrlToId(movie.trailerUrl) != null)
          .toList();
      
      if (mounted) {
        setState(() {
          _moviesWithTrailers = moviesWithTrailers;
          _isLoading = false;
        });
        
        // Initialize the first video after a short delay
        if (_moviesWithTrailers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeController(0);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trailers: $e')),
        );
      }
    }
  }

  void _initializeController(int index) {
    if (index < 0 || index >= _moviesWithTrailers.length) return;
    
    // Dispose previous controller if exists
    _controller?.dispose();
    _autoplayTimer?.cancel();
    
    final movie = _moviesWithTrailers[index];
    final videoId = YoutubePlayer.convertUrlToId(movie.trailerUrl);
    
    if (videoId == null) return;
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: _audioMuted,
        disableDragSeek: true,
        loop: false,
        enableCaption: false,
        hideControls: true, // Hide YouTube controls for cleaner look
        forceHD: true, // Try to force HD playback
        controlsVisibleAtStart: false, // Start with controls hidden
      ),
    );
    
    _controller!.addListener(_videoListener);
    
    setState(() {
      _currentIndex = index;
      // Reset UI visibility with each new video
      _uiVisible = true;
      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _uiVisible = false;
          });
        }
      });
    });
  }
  
  void _videoListener() {
    if (_controller?.value.playerState == PlayerState.ended) {
      _autoplayTimer?.cancel();
      _autoplayTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _currentIndex < _moviesWithTrailers.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }
  
  void _toggleMute() {
    setState(() {
      _audioMuted = !_audioMuted;
      if (_controller != null) {
        _audioMuted ? _controller!.mute() : _controller!.unMute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Always ensure we're in immersive mode when this tab is active
    if (_isFullScreen) {
      _setImmersiveMode();
    }
    
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading trailers...',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    if (_moviesWithTrailers.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No trailers available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadMoviesWithTrailers,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // Full-screen content with GestureDetector for UI toggle
    return GestureDetector(
      onTap: _toggleUI, // Show/hide UI on tap
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Main content: PageView of videos
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _moviesWithTrailers.length,
              onPageChanged: (index) {
                _initializeController(index);
              },
              itemBuilder: (context, index) {
                final movie = _moviesWithTrailers[index];
                final isCurrentPage = index == _currentIndex;
                
                return _buildReelItem(context, movie, isCurrentPage);
              },
            ),
            
            // UI elements with animated opacity
            AnimatedOpacity(
              opacity: _uiVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  // Top controls - simplified
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title only - removed counter
                            // Text(
                            //   'Trailers',
                            //   style: const TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            // Controls
                            Row(
                              children: [
                                // IconButton(
                                //   icon: Icon(
                                //     _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                //     color: Colors.white,
                                //   ),
                                //   onPressed: _toggleFullScreen,
                                // ),
                                IconButton(
                                  icon: Icon(
                                    _audioMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleMute,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Movie info (bottom)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? 80 : 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentIndex < _moviesWithTrailers.length) ...[
                          Text(
                            _moviesWithTrailers[_currentIndex].title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_moviesWithTrailers[_currentIndex].genres.isNotEmpty)
                            Text(
                              _moviesWithTrailers[_currentIndex].genres.join(' • '),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                                shadows: [
                                  Shadow(
                                    blurRadius: 8.0,
                                    color: Colors.black,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber[600],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _moviesWithTrailers[_currentIndex].rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _moviesWithTrailers[_currentIndex].releaseYear,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Restore UI before navigating
                                    _restoreUI();
                                    Navigator.pushNamed(
                                      context,
                                      '/movie-detail',
                                      arguments: {'id': _moviesWithTrailers[_currentIndex].id},
                                    ).then((_) {
                                      // Reset immersive mode when returning
                                      if (_isFullScreen) {
                                        _setImmersiveMode();
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.info_outline, size: 20),
                                  label: const Text('More Info'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  
                  // Side action buttons
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height / 2 - 72,
                    child: Column(
                      children: [
                        _buildActionButton(
                          Icons.thumb_up,
                          'Like',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Liked!')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.favorite_border,
                          'Save',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to My List')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.share,
                          'Share',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sharing...')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReelItem(BuildContext context, Movie movie, bool isCurrentPage) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player or thumbnail - now stretched to fill screen
          if (isCurrentPage && _controller != null)
            YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: false,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
              bottomActions: const [], // Remove default bottom controls
            )
          else
            Image.network(
              movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
                ),
              ),
            ),
              
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}