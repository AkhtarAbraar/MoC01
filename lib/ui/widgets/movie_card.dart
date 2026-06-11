import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String genre;
  final String desc;
  final String releaseDate;
  final String rating;
  final String imageUrl;
  final bool isFavorite; // <-- Added to track state
  final VoidCallback onFavoriteToggle; // <-- Added to handle taps

  const MovieCard({
    super.key,
    required this.title,
    required this.genre,
    required this.desc,
    required this.releaseDate,
    required this.rating,
    required this.imageUrl,
    required this.isFavorite, // <-- Required parameter
    required this.onFavoriteToggle, // <-- Required parameter
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
            imageUrl,
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
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        // The interactive Heart Button
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed:
                              onFavoriteToggle, // Triggers the function from home.dart
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(), // Keeps the button compact
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$releaseDate • $genre',
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
                          rating,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      desc,
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
