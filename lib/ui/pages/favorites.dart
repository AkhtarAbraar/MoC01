import 'package:flutter/material.dart';
import '../../bloc/movie_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_details.dart';

class FavoritesScreen extends StatelessWidget {
  final MovieBloc movieBloc;

  const FavoritesScreen({super.key, required this.movieBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      // Menggunakan StreamBuilder dengan initialData dari movieBloc.currentMovies
      // Sehingga data favorit langsung tampil dan tetap reaktif jika di-unfavorite
      body: StreamBuilder<MovieState>(
        initialData: MovieLoadedState(movieBloc.currentMovies),
        stream: movieBloc.stateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is MovieLoadedState) {
            // Filter hanya film yang memiliki isFavorite == true
            final favoriteMovies = state.movies.where((m) => m.isFavorite).toList();

            if (favoriteMovies.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada film favorit.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetail(movie: movie),
                        ),
                      );
                    },
                    child: MovieCard(
                      movie: movie,
                      onFavoriteToggle: () {
                        // Mengirim event toggle ke BLoC untuk membatalkan favorit
                        movieBloc.eventSink.add(ToggleFavoriteEvent(movie.id));
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Memuat...'));
        },
      ),
    );
  }
}
