import 'package:flutter/material.dart';
import '../models/movie_model.dart';

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
