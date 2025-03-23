import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';
import '../../models/movie_model.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';

class MovieService {
  late Client client;
  late Databases databases;
  late Storage storage;
  
  // Collection IDs for Appwrite
  final String _moviesCollectionId = '67d84b19003507c72532'; 
  final String _moviesBucketId = '67e0266900022e42c56b';

  MovieService() {
    _init();
  }

  void _init() {
    client = Client()
      .setEndpoint(AppConstants.appwriteEndpoint)
      .setProject(AppConstants.appwriteProjectId);
    
    // Only set self-signed in debug mode
    
      client.setSelfSigned(status: true);
    

    databases = Databases(client);
    storage = Storage(client);
  }

  // Get all movies
  Future<List<Movie>> getAllMovies() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
      );

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting movies: $e');
      rethrow;
    }
  }

  // Get featured movies
  // Future<List<Movie>> getFeaturedMovies() async {
  //   try {
  //     final response = await databases.listDocuments(
  //       databaseId: AppConstants.appwriteDatabaseId,
  //       collectionId: _moviesCollectionId,
  //       queries: [
  //         Query.equal('isFeatured', true),
  //       ],
  //     );

  //     return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
  //   } catch (e) {
  //     debugPrint('Error getting featured movies: $e');
  //     rethrow;
  //   }
  // }

  // Get movie by ID
  Future<Movie> getMovie(String id) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        documentId: id,
      );

      return Movie.fromMap(response.data);
    } catch (e) {
      debugPrint('Error getting movie: $e');
      rethrow;
    }
  }

  // Create a new movie
  Future<Movie> createMovie(Movie movie, {File? posterFile, File? backdropFile}) async {
    try {
      // First upload images if provided
      String posterImageUrl = movie.imageUrl;
      String backdropImageUrl = movie.backdropUrl;
      
      if (posterFile != null) {
        final posterUpload = await uploadImage(posterFile);
        posterImageUrl = getFileViewUrl(posterUpload.$id);
      }
      
      if (backdropFile != null) {
        final backdropUpload = await uploadImage(backdropFile);
        backdropImageUrl = getFileViewUrl(backdropUpload.$id);
      }
      
      // Create movie with image URLs
      final movieData = movie.toMap();
      movieData['imageUrl'] = posterImageUrl;
      movieData['backdropUrl'] = backdropImageUrl;
      
      final response = await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        documentId: ID.unique(),
        data: movieData,
      );

      return Movie.fromMap(response.data);
    } catch (e) {
      debugPrint('Error creating movie: $e');
      rethrow;
    }
  }

  // Update an existing movie
  Future<Movie> updateMovie(String id, Movie movie, {File? posterFile, File? backdropFile}) async {
    try {
      // First upload new images if provided
      Map<String, dynamic> updateData = movie.toMap();
      
      if (posterFile != null) {
        final posterUpload = await uploadImage(posterFile);
        updateData['imageUrl'] = getFileViewUrl(posterUpload.$id);
      }
      
      if (backdropFile != null) {
        final backdropUpload = await uploadImage(backdropFile);
        updateData['backdropUrl'] = getFileViewUrl(backdropUpload.$id);
      }
      
      final response = await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        documentId: id,
        data: updateData,
      );

      return Movie.fromMap(response.data);
    } catch (e) {
      debugPrint('Error updating movie: $e');
      rethrow;
    }
  }

  // Delete a movie
  Future<void> deleteMovie(String id) async {
    try {
      await databases.deleteDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        documentId: id,
      );
    } catch (e) {
      debugPrint('Error deleting movie: $e');
      rethrow;
    }
  }

  // Upload image to Appwrite storage
  Future<models.File> uploadImage(File file) async {
    try {
      final result = await storage.createFile(
        bucketId: _moviesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      
      return result;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  // Get URL for viewing a file
  String getFileViewUrl(String fileId) {
    return '${AppConstants.appwriteEndpoint}/storage/buckets/$_moviesBucketId/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
  }

  // Get movies by genre
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.search('genres', genre),
        ],
      );

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting movies by genre: $e');
      rethrow;
    }
  }

  // Get featured movies (for hero/carousel section)
  Future<List<Movie>> getFeaturedMovies({int limit = 5}) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.equal('isFeatured', true),
          Query.limit(limit),
        ],
      );

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting featured movies: $e');
      // Return empty list instead of throwing to make app more resilient
      return [];
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int limit = 10}) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.orderDesc('rating'),
          Query.limit(limit),
        ],
      );

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting top rated movies: $e');
      return [];
    }
  }

  // Get newest movies (for "Arrived this year" section)
  Future<List<Movie>> getNewestMovies({int limit = 8}) async {
    try {
      final currentYear = DateTime.now().year.toString();
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.equal('releaseYear', currentYear),
          Query.limit(limit),
        ],
      );

      // If we don't have enough movies from current year, just get newest
      // if (response.documents.length < limit) {
      //   final additionalResponse = await databases.listDocuments(
      //     databaseId: AppConstants.appwriteDatabaseId,
      //     collectionId: _moviesCollectionId,
      //     queries: [
      //       Query.orderDesc('releaseYear'),
      //       Query.limit(limit - response.documents.length),
      //     ],
      //   );
        
      //   final allDocs = [...response.documents, ...additionalResponse.documents];
      //   return allDocs.map((doc) => Movie.fromMap(doc.data)).toList();
      // }

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting newest movies: $e');
      return [];
    }
  }

  // Get movies by language
  Future<List<Movie>> getMoviesByLanguage(String language, {int limit = 21}) async {
    try {
      // Assuming you have a 'language' field. If not, you might need to modify this.
      // Another option is to check for titles that sound like they're in a certain language
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.search('language', language),
          Query.limit(limit),
        ],
      );
    print(response.documents);
      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();

    } catch (e) {
      debugPrint('Error getting movies by language: $e');
      return [];
    }
  }

  // Get movies by content type (movie/series)
  Future<List<Movie>> getMoviesByContentType(String contentType, {int limit = 21}) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [
          Query.equal('contentType', contentType),
          Query.limit(limit),
        ],
      );

      return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Error getting content by type: $e');
      return [];
    }
  }

  // Search movies by title
  Future<List<Movie>> searchMoviesByTitle(String query) async {
    try {
      // Check if we have a full-text index for title
      // If you don't have an index, this will fail with "general_query_invalid"
      try {
        final response = await databases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: _moviesCollectionId,
          queries: [
            Query.search('title', query),
            Query.limit(20),
          ],
        );
        
        return response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
      } catch (e) {
        // Fallback if no full-text index exists - get all and filter client-side
        debugPrint('Search error, falling back to client-side filtering: $e');
        
        final response = await databases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: _moviesCollectionId,
          queries: [Query.limit(100)],
        );
        
        final movies = response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
        
        // Client-side filtering
        return movies.where((movie) => 
          movie.title.toLowerCase().contains(query.toLowerCase())).toList();
      }
    } catch (e) {
      debugPrint('Error searching movies by title: $e');
      return [];
    }
  }

  // Search movies by genre
  Future<List<Movie>> searchMoviesByGenre(String query) async {
    try {
      // Get all movies and filter client-side by genre
      // This is because genre is an array field
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [Query.limit(100)],
      );
      
      final movies = response.documents.map((doc) => Movie.fromMap(doc.data)).toList();
      
      // Filter by genres that contain the query
      return movies.where((movie) => 
        movie.genres.any((genre) => 
          genre.toLowerCase().contains(query.toLowerCase()))).toList();
    } catch (e) {
      debugPrint('Error searching movies by genre: $e');
      return [];
    }
  }

  // General search across multiple fields
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final titleResults = await searchMoviesByTitle(query);
      final genreResults = await searchMoviesByGenre(query);
      
      // Combine results, avoiding duplicates
      final Set<String> addedIds = {};
      final List<Movie> combinedResults = [];
      
      for (final movie in titleResults) {
        if (!addedIds.contains(movie.id)) {
          combinedResults.add(movie);
          addedIds.add(movie.id);
        }
      }
      
      for (final movie in genreResults) {
        if (!addedIds.contains(movie.id)) {
          combinedResults.add(movie);
          addedIds.add(movie.id);
        }
      }
      
      return combinedResults;
    } catch (e) {
      debugPrint('Error in general search: $e');
      return [];
    }
  }

  // Get similar movies
  Future<List<Movie>> getSimilarMovies(String currentMovieId, List<String> genres, {int limit = 10}) async {
    try {
      if (genres.isEmpty) {
        // If no genres are available, return top movies instead
        return getTopRatedMovies(limit: limit);
      }
      
      // We'll try to use Appwrite queries to find movies with matching genres
      // Since genre is an array, we need a different approach
      
      // First, get movies (limited to reasonable number)
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: _moviesCollectionId,
        queries: [Query.limit(100)], // Get a larger batch for client-side filtering
      );
      
      // Convert to movies
      final allMovies = response.documents
        .map((doc) => Movie.fromMap(doc.data))
        .where((movie) => movie.id != currentMovieId) // Exclude current movie
        .toList();
      
      // Score each movie by how many genres match
      final scoredMovies = allMovies.map((movie) {
        // Count how many genres match
        final matchingGenres = movie.genres
            .where((genre) => genres.contains(genre))
            .length;
        
        // Return a movie with its matching score
        return {
          'movie': movie,
          'score': matchingGenres,
        };
      }).toList();
      
      // Sort by score (highest match first)
      scoredMovies.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      
      // Take top results
      return scoredMovies
          .take(limit)
          .map((item) => item['movie'] as Movie)
          .toList();
    } catch (e) {
      debugPrint('Error getting similar movies: $e');
      return [];
    }
  }
}