class AppConstants {
  // Appwrite Configuration
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId =
      '67d84a030030507137d5'; // Replace with your actual Project ID
  static const String appwriteDatabaseId =
      '67d84af70035c5e97ac4'; // Replace with your database ID

  // Appwrite Collection IDs
  static const String usersCollectionId = 'users';
  static const String moviesCollectionId = 'movies';
  static const String seriesCollectionId = 'series';
  static const String favoritesCollectionId = 'favorites';

  // Appwrite Database ID
  static const String databaseId =
      'your-database-id'; // Replace with your actual Database ID

  // Appwrite Storage Bucket IDs
  static const String moviePostersBucketId = 'movie-posters';
  static const String profileImagesBucketId = 'profile-images';
    static const String movieImagesBucketId = '67e0266900022e42c56b';


  // App Settings
  static const String appName = 'Spotiflix';
  static const String appVersion = '1.0.0';

  // Cache Settings
  static const int cacheExpirationInMinutes = 30;

  // API Endpoints
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey =
      'your-tmdb-api-key'; // Optional if you're using TMDB

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableProfileCustomization = true;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int defaultAnimationDuration = 300; // milliseconds
}
