import 'package:flutter/material.dart';
import '../../../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onFavoriteToggle;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            movie.imageUrl,
            width: 110,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 110,
              height: 160,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, size: 40, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 160,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW: Title and Favorite Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        // Button Favorite yang memicu BLoC Event
                        IconButton(
                          icon: Icon(
                            movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: movie.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year} • ${movie.genre}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      movie.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
