import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MovieCatalogScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Movie {
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String imageUrl;

  Movie({
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.imageUrl,
  });
}

class MovieCatalogScreen extends StatelessWidget {
  final List<Movie> movies = [
    Movie(
      title: 'Transformers: The Last Knight',
      genre: 'Action',
      year: 2017,
      rating: 5.2,
      imageUrl:
          'https://m.media-amazon.com/images/M/MV5BYWNlNjU3ZTItYTY3Mi00YTU1LTk4NjQtYjQ3MjFiNjcyODliXkEyXkFqcGc@._V1_.jpg',
    ),
    Movie(
      title: 'The Dark Knight',
      genre: 'Action',
      year: 2008,
      rating: 9.0,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/The_Dark_Knight_%282008_film%29.jpg/250px-The_Dark_Knight_%282008_film%29.jpg',
    ),
    Movie(
      title: 'Gundam: Hathaway',
      genre: 'Sci-Fi',
      year: 2021,
      rating: 7.5,

      imageUrl:
          'https://m.media-amazon.com/images/M/MV5BYjdmOTI5ZmQtOTBiOS00YmIwLWJjMDMtMWQ5MDk3YTQyYTI5XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
    ),
  ];

  MovieCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Catalog')),
      body: Column(
        children: movies.map((movie) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            clipBehavior: Clip.hardEdge,
            elevation: 3,
            child: Row(
              children: [
                Image.network(
                  movie.imageUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.movie,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${movie.year} • ${movie.genre}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
