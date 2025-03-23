class Movie {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String backdropUrl;
  final double rating;
  final List<String> genres;
  final String releaseYear;
  final String duration;
  final List<String> cast;
  final String director;
  final bool isFeatured;
  final String trailerUrl;
  final String contentType; // "movie" or "series"
  final int? seasons; // Only for series

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.backdropUrl,
    required this.rating,
    required this.genres,
    required this.releaseYear,
    required this.duration,
    required this.cast,
    required this.director,
    this.isFeatured = false,
    this.trailerUrl = '',
    this.contentType = 'movie',
    this.seasons,
  });

  // Convert to Map for Appwrite storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'backdropUrl': backdropUrl,
      'rating': rating,
      'genres': genres,
      'releaseYear': releaseYear,
      'duration': duration,
      'cast': cast,
      'director': director,
      'isFeatured': isFeatured,
      'trailerUrl': trailerUrl,
      'contentType': contentType,
      'seasons': seasons,
    };
  }

  // Create Movie object from Appwrite document
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['\$id'] ?? '',  // Make sure to handle Appwrite's ID format with $id
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      backdropUrl: map['backdropUrl'] ?? '',
      rating: _parseRating(map['rating']),
      genres: _parseStringList(map['genres']),
      releaseYear: map['releaseYear'] ?? '',
      duration: map['duration'] ?? '',
      cast: _parseStringList(map['cast']),
      director: map['director'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      trailerUrl: map['trailerUrl'] ?? '',
      contentType: map['contentType'] ?? 'movie',
      seasons: map['seasons'],
    );
  }

  // Helper methods to safely parse data
  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is int) return rating.toDouble();
    if (rating is double) return rating;
    if (rating is String) {
      try {
        return double.parse(rating);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((item) => item.toString()).toList();
    }
    return [];
  }
}