import 'package:flutter/material.dart';

class MovieDetail extends StatelessWidget {
  final String title;
  final String genre;
  final String desc;
  final String releaseDate;
  final String rating;
  final String imageUrl;

  const MovieDetail({
    super.key,
    required this.title,
    required this.genre,
    required this.desc,
    required this.releaseDate,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // SingleChildScrollView allows the page to scroll if the description is very long
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Hero Image
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.movie, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meta Info Row (Year, Genre, Rating)
                  Row(
                    children: [
                      Text(
                        '$releaseDate • $genre',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32, thickness: 1),

                  // Description
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(desc, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
