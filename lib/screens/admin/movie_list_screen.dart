import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/api/movie_service.dart';
import 'add_movie_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieService _movieService = MovieService();
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final movies = await _movieService.getAllMovies();
      
      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load movies: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMovie(String id) async {
    try {
      await _movieService.deleteMovie(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully')),
      );
      _loadMovies(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting movie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovies,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _movies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          const Text('No movies found'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Movie'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddMovieScreen(),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  _loadMovies();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMovies,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: 50,
                                  height: 75,
                                  child: movie.imageUrl.isNotEmpty
                                      ? Image.network(
                                          movie.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(Icons.broken_image),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.movie),
                                        ),
                                ),
                              ),
                              title: Text(movie.title),
                              subtitle: Text(
                                '${movie.releaseYear} • ${movie.duration}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddMovieScreen(
                                            movieToEdit: movie,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _loadMovies();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Movie'),
                                          content: Text(
                                            'Are you sure you want to delete "${movie.title}"? This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteMovie(movie.id);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/movie-detail',
                                  arguments: {
                                    'id': movie.id,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMovieScreen(),
            ),
          ).then((value) {
            if (value == true) {
              _loadMovies();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}