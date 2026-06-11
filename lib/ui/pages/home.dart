import 'package:flutter/material.dart';
import '../widgets/movie_card.dart';
import 'movie_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Moved the list INSIDE the State class and removed 'const'
  // so we can modify the 'isFavorite' property.
  List<Map<String, dynamic>> movieList = [
    {
      'title': 'Transformers: The Last Knight',
      'genre': 'Action',
      'desc': 'A deadly threat from Earth\'s history reappears...',
      'year': '2017',
      'rating': '5.2',
      'isFavorite': false,
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BYWNlNjU3ZTItYTY3Mi00YTU1LTk4NjQtYjQ3MjFiNjcyODliXkEyXkFqcGc@._V1_.jpg',
    },
    {
      'title': 'The Dark Knight',
      'genre': 'Action',
      'desc': 'When the menace known as the Joker wreaks havoc...',
      'year': '2008',
      'rating': '9.0',
      'isFavorite': false,
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/The_Dark_Knight_%282008_film%29.jpg/250px-The_Dark_Knight_%282008_film%29.jpg',
    },
    {
      'title': 'Gundam: Hathaway',
      'genre': 'Sci-Fi',
      'desc': 'A young pilot named Hathaway is caught in the middle...',
      'year': '2021',
      'rating': '7.5',
      'isFavorite': false,
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BYjdmOTI5ZmQtOTBiOS00YmIwLWJjMDMtMWQ5MDk3YTQyYTI5XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
    },
    {
      'title': 'The Nun',
      'genre': 'Horror',
      'desc': 'A young nun is possessed by a demonic entity...',
      'year': '2018',
      'rating': '5.3',
      'isFavorite': false,
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BMjM3NzQ5NDcxOF5BMl5BanBnXkFtZTgwNzM4MTQ5NTM@._V1_.jpg',
    },
    {
      'title': 'Merah Putih: One For All',
      'genre': 'Propaganda',
      'desc':
          'Eight diverse kids form "Tim Merah Putih" to guard Indonesia\'s flag...',
      'year': '2025',
      'rating': '1.0',
      'isFavorite': false,
      'imageUrl':
          'https://m.media-amazon.com/images/M/MV5BMDk5YTJlMjktOWQxNS00ZTZiLTgxYWUtMTI0M2VkNGU0MjZlXkEyXkFqcGc@._V1_QL75_UY281_CR4,0,190,281_.jpg',
    },
  ];

  // 2. The function that flips the true/false value and rebuilds the screen
  void toggleFavorite(int index) {
    setState(() {
      movieList[index]['isFavorite'] = !movieList[index]['isFavorite'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: movieList.length,
          itemBuilder: (context, index) {
            final movie = movieList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetail(
                      title: movie['title']?.toString() ?? 'Unknown',
                      genre: movie['genre']?.toString() ?? 'Unknown',
                      desc:
                          movie['desc']?.toString() ??
                          'No description available',
                      releaseDate: movie['year']?.toString() ?? 'Unknown',
                      rating: movie['rating']?.toString() ?? 'Unknown',
                      imageUrl: movie['imageUrl']?.toString() ?? '',
                    ),
                  ),
                );
              },
              child: MovieCard(
                title: movie['title']?.toString() ?? 'Unknown',
                genre: movie['genre']?.toString() ?? 'Unknown',
                desc: movie['desc']?.toString() ?? 'No description available',
                releaseDate: movie['year']?.toString() ?? 'Unknown',
                rating: movie['rating']?.toString() ?? 'Unknown',
                imageUrl: movie['imageUrl']?.toString() ?? '',

                // 3. Pass the state and the function down to the card
                isFavorite: movie['isFavorite'] as bool? ?? false,
                onFavoriteToggle: () => toggleFavorite(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
