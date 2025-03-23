import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/api/movie_service.dart';
import '../components/search_sugestion.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Movie> _searchResults = [];
  List<Movie> _recentSearches = [];
  List<String> _searchSuggestions = [
    'Action', 'Comedy', 'Drama', 'Thriller', 'Sci-Fi', 
    'Horror', 'Romance', 'Animation', 'Documentary', 'Bollywood'
  ];
  
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Load recent searches from storage or caching system
  Future<void> _loadRecentSearches() async {
    try {
      // Get top rated movies as recent search examples
      final movies = await _movieService.getTopRatedMovies(limit: 5);
      
      if (mounted) {
        setState(() {
          _recentSearches = movies;
        });
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  // Perform search with debounce
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
            _errorMessage = 'Search failed: $e';
          });
        }
      }
    });
  }

  // Search movies in Appwrite database
  Future<List<Movie>> _searchMovies(String query) async {
    // Search by title and description
    try {
      // We'll try multiple ways to find relevant results
      final titleResults = await _movieService.searchMoviesByTitle(query);
      final genreResults = await _movieService.searchMoviesByGenre(query);
      
      // Combine results removing duplicates
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

  // Handle search suggestion tap
  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  // Handle movie item tap
  void _onMovieTap(Movie movie) {
    // Navigate to movie details
    Navigator.pushNamed(
      context,
      '/movie-detail',
      arguments: {'id': movie.id},
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar with text field instead of SearchBar for more control
            TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search for movies, genres, actors...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    ) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // Main content area
            Expanded(
              child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _performSearch(_searchController.text),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _isSearching 
                  ? _buildSearchResults()
                  : _buildSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Search results list
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return SearchResultCard(
          movie: movie,
          onTap: () => _onMovieTap(movie),
        );
      },
    );
  }
  
  // Suggestions and recent searches
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular searches / categories
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Horizontal suggestions
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _searchSuggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onSuggestionTap(_searchSuggestions[index]),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _searchSuggestions[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent searches
          const Text(
            'You Might Like',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Recent searches list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final movie = _recentSearches[index];
              return SearchSuggestionCard(
                movie: movie,
                onTap: () => _onMovieTap(movie),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Search result card that displays movie information
class SearchResultCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  
  const SearchResultCard({
    Key? key, 
    required this.movie, 
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Movie poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 100,
                  child: Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.white),
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.genres.take(2).join(' • '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          movie.duration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Play/details icon
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Update your SearchSuggestionCard component
class SearchSuggestionCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  
  const SearchSuggestionCard({
    Key? key, 
    required this.movie, 
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          movie.imageUrl,
          width: 50,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[800],
            width: 50,
            height: 70,
            child: const Icon(Icons.image_not_supported, color: Colors.white54),
          ),
        ),
      ),
      title: Text(
        movie.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${movie.releaseYear} • ${movie.rating} ★',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}