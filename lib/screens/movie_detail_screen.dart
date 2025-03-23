import 'package:expproj/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie_model.dart';
import '../services/api/movie_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/animation.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  Movie? _movie;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isTrailerVisible = false;
  YoutubePlayerController? _youtubeController;
  
  // Add these new fields for similar movies
  List<Movie> _similarMovies = [];
  bool _isLoadingSimilarMovies = false;

  // Add these fields to _MovieDetailScreenState
  final List<GlobalKey> _animationKeys = List.generate(6, (_) => GlobalKey());
  bool _startContentAnimation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMovieDetails();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadMovieDetails() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No movie information provided';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      String movieId = args['id'] as String;

      try {
        final movie = await _movieService.getMovie(movieId);
        if (mounted) {
          setState(() {
            _movie = movie;
            _isLoading = false;
          });
          
          // Trigger content animations after a short delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _startContentAnimation = true;
              });
            }
          });
          
          // Load similar movies after the main movie is loaded
          _loadSimilarMovies(movie);
        }
      } catch (e) {
        // If movie not found in database (for demo purposes), create a mock movie
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          setState(() {
            _movie = Movie(
              id: movieId,
              title: args['title'] as String,
              description:
                  'This is a sample description for ${args['title']}. In a real app, this would be fetched from the database with rich formatting and details about the plot, main characters, and more.',
              imageUrl: args['imageUrl'] as String,
              backdropUrl: args['imageUrl']
                  as String, // Using same image as backdrop for demo
              rating: 4.5,
              genres: ['Action', 'Drama', 'Thriller'],
              releaseYear: '2023',
              duration: '2h 15m',
              cast: ['Actor One', 'Actor Two', 'Actor Three', 'Actor Four'],
              director: 'Famous Director',
              isFeatured: true,
              trailerUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load movie details: $e';
        });
      }
    }
  }
  
  // Add this new method to load similar movies
  Future<void> _loadSimilarMovies(Movie movie) async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingSimilarMovies = true;
    });
    
    try {
      // Get movies with similar genres, excluding the current one
      final similarMovies = await _movieService.getSimilarMovies(
        movie.id,
        movie.genres,
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          _similarMovies = similarMovies;
          _isLoadingSimilarMovies = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading similar movies: $e');
      if (mounted) {
        setState(() {
          _isLoadingSimilarMovies = false;
        });
      }
    }
  }

  // Add this method to extract YouTube video ID
  String? _getYoutubeVideoId(String url) {
    if (url.isEmpty) return null;

    try {
      return YoutubePlayer.convertUrlToId(url);
    } catch (e) {
      debugPrint('Error extracting YouTube ID: $e');
      return null;
    }
  }

  // Add this method to initialize the YouTube player
  void _initializeYoutubePlayer(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  // Replace the _showTrailer method with this enhanced version

  void _showTrailer(BuildContext context, String videoId) {
    _initializeYoutubePlayer(videoId);

    setState(() {
      _isTrailerVisible = true;
    });

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_movie?.title} - Trailer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _youtubeController?.pause();
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Theme.of(context).colorScheme.primary,
                  progressColors: ProgressBarColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    handleColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  onReady: () {
                    debugPrint('YouTube Player is ready');
                  },
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(
                      isExpanded: true,
                      colors: ProgressBarColors(
                        playedColor: Theme.of(context).colorScheme.primary,
                        handleColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    RemainingDuration(),
                    const PlaybackSpeedButton(),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.fullscreen, size: 20),
                      label: const Text('Fullscreen'),
                      onPressed: () {
                        _youtubeController?.pause();
                        Navigator.pop(context);

                        // Navigate to fullscreen player
                        Navigator.pushNamed(
                          context,
                          '/trailer-player',
                          arguments: {
                            'videoId': videoId,
                            'title': _movie?.title ?? 'Trailer',
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Share'),
                      onPressed: () {
                        final trailerUrl = _movie?.trailerUrl ?? '';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sharing: $trailerUrl')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isTrailerVisible = false;
      });
      _youtubeController?.dispose();
      _youtubeController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    if (_isLoading) {
      return Scaffold(
        body: _buildLoadingState(),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage ?? 'Unknown error occurred'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, color: Colors.white),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _movie == null ? _buildLoadingState() : _buildMovieDetails(),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[850]!,
      period: const Duration(milliseconds: 1500),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero backdrop
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[800],
            ),
            
            // Movie info section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Movie poster
                  Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Title and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          height: 24,
                          width: double.infinity,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 8),
                        
                        // Year/duration row
                        Row(
                          children: [
                            Container(
                              height: 16,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 14,
                              width: 40,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 14,
                              width: 40,
                              color: Colors.grey[800],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating
                        Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(width: 4),
                            Container(
                              height: 14,
                              width: 30,
                              color: Colors.grey[800],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Play button
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Trailer & download buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Description section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Container(
                    height: 20,
                    width: 100,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description lines
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity * 0.8,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),
            
            // Genres section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Container(
                    height: 20,
                    width: 60,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 12),
                  
                  // Genre pills
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        height: 30,
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Cast section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Container(
                    height: 20,
                    width: 90,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 12),
                  
                  // Cast list
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Name
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 4),
                              // Role
                              Container(
                                height: 10,
                                width: 40,
                                color: Colors.grey[800],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Similar movies section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Container(
                    height: 20,
                    width: 120,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 12),
                  
                  // Similar movies list
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie poster
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Title
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 4),
                              // Rating
                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    color: Colors.grey[800],
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    height: 10,
                                    width: 30,
                                    color: Colors.grey[800],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom spacing
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

// Update to add animated sections
Widget _buildMovieDetails() {
  final hasTrailer = _movie!.trailerUrl.isNotEmpty &&
      _getYoutubeVideoId(_movie!.trailerUrl) != null;

  // Define sections with animation delay index
  final heroSection = _buildHeroSection(hasTrailer);
  final actionButtonsSection = _buildAnimatedChild(_buildActionButtons(hasTrailer), 0);
  final descriptionSection = _buildAnimatedChild(_buildDescriptionSection(), 1);
  final genresSection = _buildAnimatedChild(_buildGenresSection(), 2);
  final castSection = _buildAnimatedChild(_buildCastSection(), 3);
  final similarMoviesSection = _buildAnimatedChild(_buildSimilarMoviesWrapper(), 4);

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero header with backdrop image (not animated for better UX)
        heroSection,
        
        // Action buttons
        actionButtonsSection,
        
        // Description
        descriptionSection,
        
        // Genres
        genresSection,
        
        // Cast
        castSection,
        
        // Similar content section
        similarMoviesSection,
        
        // Bottom spacing
        const SizedBox(height: 32),
      ],
    ),
  );
}

// Now create individual section builder methods:

Widget _buildHeroSection(bool hasTrailer) {
  return Stack(
    children: [
      // Backdrop image
      SizedBox(
        height: 300,
        width: double.infinity,
        child: Hero(
          tag: 'movie_backdrop_${_movie!.id}',
          child: Image.network(
            _movie!.backdropUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      
      // Top gradient for app bar visibility
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.2),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
      ),
      
      // Play button overlay for trailer if available
      if (hasTrailer)
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () {
                final videoId = _getYoutubeVideoId(_movie!.trailerUrl);
                if (videoId != null) {
                  _showTrailer(context, videoId);
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      
      // Bottom gradient for text visibility
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 0.75, 1.0],
            ),
          ),
        ),
      ),
      
      // Movie poster, title, and basic info
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Movie poster
              Hero(
                tag: 'movie_poster_${_movie!.id}',
                child: Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _movie!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Movie info (title, year, rating)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      _movie!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Year and duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _movie!.releaseYear,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _movie!.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (_movie!.contentType == 'series') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'TV',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _movie!.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
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
    ],
  );
}

Widget _buildActionButtons(bool hasTrailer) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: [
        // Your existing action buttons...
        ElevatedButton.icon(
          // Play button code...
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Playing movie...')),
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Your existing trailer and download buttons...
            if (hasTrailer)
              Expanded(
                flex: 1,
               
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                        minimumSize: Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final videoId =
                        _getYoutubeVideoId(_movie!.trailerUrl);
                    if (videoId != null) {
                      _showTrailer(context, videoId);
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Trailer'),
                ),
              ),
            SizedBox(
              width: 8,
            ),
            // Download button
            Expanded(
           flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                    minimumSize: Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading...')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildDescriptionSection() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _movie!.description,
          style: TextStyle(
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget _buildGenresSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _movie!.genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              child: Text(
                genre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Widget _buildCastSection() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast & Crew',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _movie!.cast.length + 1, // +1 for director
            itemBuilder: (context, index) {
              if (index == 0) {
                // Director
                return _buildCastItem(
                  name: _movie!.director,
                  role: 'Director',
                );
              } else {
                // Cast
                return _buildCastItem(
                  name: _movie!.cast[index - 1],
                  role: 'Actor',
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildSimilarMoviesWrapper() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'More Like This',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_similarMovies.length > 5)
              TextButton(
                onPressed: () {
                  // Your existing code...
                  Navigator.pushNamed(
                    context,
                    '/movies-by-genre',
                    arguments: {'genres': _movie!.genres},
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSimilarMoviesSection(),
      ],
    ),
  );
}

  Widget _buildCastItem({required String name, required String role}) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Role
          Text(
            role,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  // Replace the existing "More Like This" section with this:
  Widget _buildSimilarMoviesSection() {
    if (_isLoadingSimilarMovies) {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[900]!,
              highlightColor: Colors.grey[800]!,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      );
    }
    
    if (_similarMovies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "No similar titles found",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarMovies.length,
        itemBuilder: (context, index) {
          final similarMovie = _similarMovies[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(),
                  settings: RouteSettings(
                    arguments: {'id': similarMovie.id},
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        similarMovie.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[900]!,
                            highlightColor: Colors.grey[800]!,
                            child: Container(
                              color: Colors.grey[900],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      similarMovie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber[600],
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        similarMovie.rating.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Create a rise animation widget
  Widget _buildAnimatedChild(Widget child, int index) {
    return AnimatedOpacity(
      opacity: _startContentAnimation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _startContentAnimation ? Offset.zero : const Offset(0, 0.1),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutQuart,
        child: child,
      ),
    );
  }
}
