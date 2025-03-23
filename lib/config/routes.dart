import 'package:expproj/screens/admin/add_movie_screen.dart';
import 'package:expproj/screens/movie_detail_screen.dart';
import 'package:expproj/screens/trailer_player_screen.dart';
import 'package:flutter/material.dart';
import '../views/authentication/login_page.dart';
import '../views/authentication/signup_page.dart';
import '../views/shared/app_scaffold.dart';
import '../screens/admin/movie_list_screen.dart';

class AppRoutes {
  static final Map<String, Widget Function(BuildContext)> routes = {
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/home': (context) => const AppScaffold(),
    '/movie-detail': (context) => const MovieDetailScreen(),
    '/admin/add-movie': (context) => const AddMovieScreen(),
    '/admin/movies': (context) => const MovieListScreen(),
    // Add other routes as needed
    '/trailer-player': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return TrailerPlayerScreen(
        videoId: args['videoId'] as String,
        title: args['title'] as String,
      );
    },
  };
}