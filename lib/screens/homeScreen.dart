import 'package:carousel_slider/carousel_slider.dart';
import 'package:expproj/components/section_builder.dart';
import 'package:expproj/screens/category_movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:expproj/services/session_manager.dart';
import '../utils/admin_access.dart';
import '../services/api/movie_service.dart';
import '../models/movie_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imageUrls = [
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
  ];

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _isAdmin = false;

  final MovieService _movieService = MovieService();

  // Data for sections
  bool _isLoading = true;
  List<Movie> _featuredMovies = [];
  List<Movie> _topMovies = [];
  List<Movie> _newMovies = [];
  List<Movie> _hindiMovies = [];
  List<Movie> _series = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAdminStatus();
    _loadMovieData(); // Add this line
  }

  Future<void> _loadUserData() async {
    final user = await SessionManager.getUser();
    setState(() {
      userData = user;
      isLoading = false;
    });
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AdminAccess.isUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  // Add this method to load all movie data
  Future<void> _loadMovieData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all data in parallel for better performance
      final results = await Future.wait([
        _movieService.getFeaturedMovies(limit: 5),
        _movieService.getTopRatedMovies(limit: 10),
        _movieService.getNewestMovies(limit: 8),
        _movieService.getMoviesByLanguage('Hindi', limit: 21),
        _movieService.getMoviesByContentType('series', limit: 21),
      ]);

      if (mounted) {
        setState(() {
          _featuredMovies = results[0];
          _topMovies = results[1];
          _newMovies = results[2];
          _hindiMovies = results[3];
          _series = results[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading movie data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movies: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMovieData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero carousel section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: Stack(
                        children: [
                          Container(
                            color: const Color(0xff121212),
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: _featuredMovies.isEmpty
                                ? CarouselSlider(
                                    options: CarouselOptions(
                                      height: double.infinity,
                                      viewportFraction: 1.0,
                                      autoPlay: true,
                                      autoPlayInterval:
                                          const Duration(seconds: 7),
                                      enableInfiniteScroll: true,
                                    ),
                                    items: imageUrls.map((url) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.white,
                                            ),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.fitHeight,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[800]!,
                                                  highlightColor:
                                                      Colors.grey[700]!,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    color: Colors.grey[300],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  )
                                : CarouselSlider(
                                    options: CarouselOptions(
                                      height: double.infinity,
                                      viewportFraction: 1.1,
                                      autoPlay: true,
                                      autoPlayInterval:
                                          const Duration(seconds: 7),
                                      enableInfiniteScroll:
                                          _featuredMovies.length > 1,
                                    ),
                                    items: _featuredMovies.map((movie) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/movie-detail',
                                                arguments: {'id': movie.id},
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0),
                                                  child: Image.network(
                                                    movie.backdropUrl.isNotEmpty
                                                        ? movie.imageUrl
                                                        : movie.imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: double.infinity,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey[800]!,
                                                        highlightColor:
                                                            Colors.grey[700]!,
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[900],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                            size: 50,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                // Add title overlay
                                                // Positioned(
                                                //   bottom: 130, // Position above the bottom gradient
                                                //   left: 20,
                                                //   right: 20,
                                                //   child: Column(
                                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                                //     children: [
                                                //       Text(
                                                //         movie.title,
                                                //         style: const TextStyle(
                                                //           fontSize: 24,
                                                //           fontWeight: FontWeight.bold,
                                                //           color: Colors.white,
                                                //           shadows: [
                                                //             Shadow(
                                                //               color: Colors.black,
                                                //               blurRadius: 8,
                                                //             ),
                                                //           ],
                                                //         ),
                                                //       ),
                                                //       if (movie.genres.isNotEmpty)
                                                //         Padding(
                                                //           padding: const EdgeInsets.only(top: 8.0),
                                                //           child: Text(
                                                //             movie.genres.take(3).join(' • '),
                                                //             style: TextStyle(
                                                //               fontSize: 14,
                                                //               color: Colors.grey[300],
                                                //               shadows: const [
                                                //                 Shadow(
                                                //                   color: Colors.black,
                                                //                   blurRadius: 8,
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //         ),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                          ),
                          // Your existing gradient overlays...
                          Positioned(
                            bottom: 0,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              height: 150, // Reduced from 400 to 150
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(
                                      255, 18, 18, 18), // Solid dark at bottom
                                  Color.fromARGB(
                                      240, 18, 18, 18), // Very strong
                                  Color.fromARGB(
                                      200, 18, 18, 18), // Strong fade
                                  Color.fromARGB(
                                      160, 18, 18, 18), // Medium fade
                                  Color.fromARGB(120, 18, 18, 18), // Light fade
                                  Color.fromARGB(
                                      80, 18, 18, 18), // Very light fade
                                  Color.fromARGB(
                                      40, 18, 18, 18), // Barely visible
                                  Colors.transparent // Completely transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [
                                  0.0,
                                  0.15,
                                  0.30,
                                  0.45,
                                  0.60,
                                  0.75,
                                  0.90,
                                  1.0
                                ],
                              )),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 20), // Add padding from bottom
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Enhanced Add to List button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          // Add to list functionality
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Added to My List')),
                                          );
                                        },
                                        icon: const Icon(Icons.add_rounded,
                                            color: Colors.white, size: 24),
                                        iconSize: 24,
                                      ),
                                    ),

                                    // Enhanced Play button
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          if (_featuredMovies.isNotEmpty) {
                                            Navigator.pushNamed(
                                              context,
                                              '/movie-detail',
                                              arguments: {
                                                'id': _featuredMovies.first.id
                                              },
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          fixedSize: const Size(
                                              140, 45), // Slightly larger
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          foregroundColor: Colors.black,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Play",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Enhanced Info button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          if (_featuredMovies.isNotEmpty) {
                                            Navigator.pushNamed(
                                              context,
                                              '/movie-detail',
                                              arguments: {
                                                'id': _featuredMovies.first.id
                                              },
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                            Icons.info_outline_rounded,
                                            color: Colors.white,
                                            size: 24),
                                        iconSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // Dynamic sections based on database data
                    if (_topMovies.isNotEmpty)
                      _buildDynamicSection(
                        title: "Top 10",
                        movies: _topMovies,
                        showRanking: true,
                      ),

                    if (_newMovies.isNotEmpty)
                      _buildDynamicSection(
                        title: "Arrived this year",
                        movies: _newMovies,
                      ),

                    if (_hindiMovies.isNotEmpty)
                      _buildDynamicSection(
                        title: "Latest in Hindi",
                        movies: _hindiMovies,
                      ),

                    if (_series.isNotEmpty)
                      _buildDynamicSection(
                        title: "Top Series",
                        movies: _series,
                      ),

                    // Add a catch-all section if the database is empty
                    if (_topMovies.isEmpty &&
                        _newMovies.isEmpty &&
                        _hindiMovies.isEmpty &&
                        _series.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.movie_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No movies available yet. Add some movies to get started!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // floatingActionButton: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     // Reels button - visible to all users

      //     // Admin button - visible only to admins
      //     if (_isAdmin)
      //       FloatingActionButton(
      //         heroTag: 'admin_button',
      //         onPressed: () => _showMovieManagementOptions(context),
      //         backgroundColor: Theme.of(context).colorScheme.primary,
      //         child: const Icon(Icons.movie_filter),
      //         tooltip: 'Manage Movies',
      //       ),
      //   ],
      // ),
    );
  }

  // Get appropriate greeting based on time of day

  // Get initials from full name

  // Build a shimmering loading effect for the text

  // Add this method to show movie management options
  void _showMovieManagementOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff121212),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Movie Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildAdminOption(
              context,
              icon: Icons.add_circle_outline,
              title: 'Add New Movie',
              subtitle: 'Create a new movie entry with details',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/add-movie');
              },
            ),
            const Divider(color: Colors.grey, height: 24, thickness: 0.2),
            _buildAdminOption(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit Existing Movies',
              subtitle: 'Update or modify movie information',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/movies');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  // Method to build dynamic sections
  Widget _buildDynamicSection({
    required String title,
    required List<Movie> movies,
    bool showRanking = false,
  }) {
    // Determine category type based on the title
    String categoryType = 'all';
    String? genre;
    String? language;
    String? contentType;

    if (title == "Top 10") {
      categoryType = 'top';
    } else if (title == "Arrived this year") {
      categoryType = 'new';
    } else if (title == "Latest in Hindi") {
      categoryType = 'language';
      language = 'Hindi';
    } else if (title == "Top Series") {
      categoryType = 'contentType';
      contentType = 'series';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the category page with a hero animation
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CategoryMoviesScreen(
                        title: title,
                        categoryType: categoryType,
                        genre: genre,
                        language: language,
                        contentType: contentType,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutQuart;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'See All ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildMovieCard(context, index, movie, showRanking);
            },
          ),
        ),
      ],
    );
  }

  // Method to build individual movie cards
  Widget _buildMovieCard(
      BuildContext context, int index, Movie movie, bool showRanking) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/movie-detail',
          arguments: {'id': movie.id},
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 37, 35, 35),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      movie.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[800],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay for title visibility
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Ranking number
                  if (showRanking)
                    Positioned(
                      bottom: -8,
                      right: 4,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 90,
                          height: 1,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 12,
                              offset: const Offset(2, 2),
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 6,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Title and info
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber[600],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
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
    );
  }

  // Keep your existing methods...
}
