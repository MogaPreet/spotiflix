import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/api/movie_service.dart';
import '../config/theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Movie> _searchResults = [];
  List<Movie> _recommendedMovies = [];

  // Categories using theme-aligned colors
  List<Map<String, dynamic>> get _searchCategories => [
        {
          'name': 'Action',
          'icon': Icons.local_fire_department_rounded,
          'gradient': [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.7)
          ]
        },
        {
          'name': 'Comedy',
          'icon': Icons.sentiment_very_satisfied_rounded,
          'gradient': [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withValues(alpha: 0.7)
          ]
        },
        {
          'name': 'Drama',
          'icon': Icons.theater_comedy_rounded,
          'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)]
        },
        {
          'name': 'Thriller',
          'icon': Icons.psychology_rounded,
          'gradient': [AppTheme.textSecondaryColor, const Color(0xFF6B7280)]
        },
        {
          'name': 'Sci-Fi',
          'icon': Icons.rocket_launch_rounded,
          'gradient': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]
        },
        {
          'name': 'Horror',
          'icon': Icons.nights_stay_rounded,
          'gradient': [
            AppTheme.errorColor,
            AppTheme.errorColor.withValues(alpha: 0.7)
          ]
        },
        {
          'name': 'Romance',
          'icon': Icons.favorite_rounded,
          'gradient': [const Color(0xFFEC4899), const Color(0xFFF472B6)]
        },
        {
          'name': 'Animation',
          'icon': Icons.animation_rounded,
          'gradient': [const Color(0xFF14B8A6), const Color(0xFF5EEAD4)]
        },
        {
          'name': 'Documentary',
          'icon': Icons.videocam_rounded,
          'gradient': [const Color(0xFF78716C), const Color(0xFFA8A29E)]
        },
        {
          'name': 'Bollywood',
          'icon': Icons.movie_filter_rounded,
          'gradient': [
            AppTheme.primaryColor.withValues(alpha: 0.9),
            const Color(0xFFfca5a5)
          ]
        },
      ];

  bool _isSearching = false;
  bool _isLoading = false;
  bool _isFocused = false;
  Timer? _debounce;
  String _errorMessage = '';

  // Animation controllers
  late AnimationController _searchBarAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _searchBarGlowAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRecommendedMovies();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _initAnimations() {
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _searchBarGlowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _searchBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _contentAnimationController.forward();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _searchBarAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendedMovies() async {
    try {
      final movies = await _movieService.getTopRatedMovies(limit: 10);
      if (mounted) {
        setState(() {
          _recommendedMovies = movies;
        });
      }
    } catch (e) {
      debugPrint('Error loading recommended movies: $e');
    }
  }

  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {
      _isSearching = query.isNotEmpty;
      if (!_isSearching) {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = '';
        return;
      }
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final results = await _searchMovies(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _errorMessage = 'Search failed. Please try again.';
          });
        }
      }
    });
  }

  Future<List<Movie>> _searchMovies(String query) async {
    try {
      final titleResults = await _movieService.searchMoviesByTitle(query);
      final genreResults = await _movieService.searchMoviesByGenre(query);

      final allResults = [...titleResults];
      for (final movie in genreResults) {
        if (!allResults.any((m) => m.id == movie.id)) {
          allResults.add(movie);
        }
      }
      return allResults;
    } catch (e) {
      debugPrint('Error searching movies: $e');
      rethrow;
    }
  }

  void _onCategoryTap(String category) {
    _searchController.text = category;
    _performSearch(category);
  }

  void _onMovieTap(Movie movie) {
    Navigator.pushNamed(
      context,
      '/movie-detail',
      arguments: {'id': movie.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
              AppTheme.backgroundColor.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Search',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: AppTheme.textPrimaryColor,
                              ),
                    ),
                    const Spacer(),
                    _buildMicButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Animated premium search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPremiumSearchBar(),
              ),
              const SizedBox(height: 24),

              // Main content area
              Expanded(
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: _isLoading
                      ? _buildShimmerLoading()
                      : _errorMessage.isNotEmpty
                          ? _buildErrorState()
                          : _isSearching
                              ? _buildSearchResults()
                              : _buildDiscoverContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.3),
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Voice search coming soon!'),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.mic_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarGlowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(
                          alpha: _searchBarGlowAnimation.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.textPrimaryColor
                          .withValues(alpha: _isFocused ? 0.12 : 0.08),
                      AppTheme.textPrimaryColor
                          .withValues(alpha: _isFocused ? 0.06 : 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFocused
                        ? AppTheme.primaryColor.withValues(alpha: 0.5)
                        : AppTheme.textSecondaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _performSearch,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: AppTheme.primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Movies, actors, genres...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                        size: 24,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.textSecondaryColor
                                    .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppTheme.textSecondaryColor,
                                size: 16,
                              ),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: _buildShimmerCard(),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.textSecondaryColor.withValues(alpha: 0.1),
            AppTheme.textSecondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Poster shimmer
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.textSecondaryColor.withValues(alpha: 0.15),
                  AppTheme.textSecondaryColor.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.08),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.errorColor.withValues(alpha: 0.2),
                    AppTheme.errorColor.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              onTap: () => _performSearch(_searchController.text),
              label: 'Try Again',
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppTheme.textPrimaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptySearchState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _PremiumSearchResultCard(
                  movie: movie,
                  onTap: () => _onMovieTap(movie),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.textSecondaryColor.withValues(alpha: 0.15),
                    AppTheme.textSecondaryColor.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.movie_filter_outlined,
                size: 64,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No movies found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try searching for a different title or genre',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Clear Search'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Browse Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Animated categories grid
          _buildCategoriesGrid(),
          const SizedBox(height: 32),

          // Recommended Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor.withValues(alpha: 0.2),
                        AppTheme.secondaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recommended For You',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recommended movies list
          _buildRecommendedMovies(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _searchCategories.length,
        itemBuilder: (context, index) {
          final category = _searchCategories[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 80)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _CategoryChip(
                  name: category['name'] as String,
                  icon: category['icon'] as IconData,
                  gradientColors: category['gradient'] as List<Color>,
                  onTap: () => _onCategoryTap(category['name'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendedMovies() {
    if (_recommendedMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _recommendedMovies.length,
      itemBuilder: (context, index) {
        final movie = _recommendedMovies[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _RecommendedMovieCard(
                  movie: movie,
                  index: index,
                  onTap: () => _onMovieTap(movie),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Category Chip Widget
class _CategoryChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppTheme.textPrimaryColor,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Premium Search Result Card
class _PremiumSearchResultCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _PremiumSearchResultCard({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.textSecondaryColor.withValues(alpha: 0.12),
                  AppTheme.textSecondaryColor.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Movie poster with hero animation potential
                      Hero(
                        tag: 'search_poster_${movie.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              movie.imageUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.textSecondaryColor
                                          .withValues(alpha: 0.3),
                                      AppTheme.textSecondaryColor
                                          .withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.movie_rounded,
                                  color: AppTheme.textSecondaryColor
                                      .withValues(alpha: 0.5),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Movie info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            _buildGenreTags(),
                            const SizedBox(height: 10),
                            _buildMetaInfo(),
                          ],
                        ),
                      ),

                      // Arrow icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreTags() {
    final genres = movie.genres.take(2).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            genre,
            style: TextStyle(
              color: AppTheme.textPrimaryColor.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetaInfo() {
    return Row(
      children: [
        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryColor.withValues(alpha: 0.25),
                AppTheme.secondaryColor.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                movie.rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Year
        Text(
          movie.releaseYear,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 10),

        // Duration
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 14,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            const Text(
              '',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Recommended Movie Card
class _RecommendedMovieCard extends StatelessWidget {
  final Movie movie;
  final int index;
  final VoidCallback onTap;

  const _RecommendedMovieCard({
    required this.movie,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.textSecondaryColor.withValues(alpha: 0.08),
                  AppTheme.textSecondaryColor.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                // Rank number
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Movie poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    movie.imageUrl,
                    width: 55,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 55,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.textSecondaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.movie_rounded,
                        color:
                            AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Movie info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${movie.releaseYear} • ${movie.genres.take(1).join()}',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Play icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
