import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/movie_bloc.dart';
import '../../bloc/favorite_bloc.dart';
import '../../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_details.dart';

/// A screen displaying only the movies that the user has marked as favorite.
class FavoritesScreen extends StatelessWidget {
  
  /// Constructor for FavoritesScreen.
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, movieState) {
          // Ambil daftar seluruh film dari MovieBloc
          List<Movie> allMovies = [];
          if (movieState is MovieLoadedState) {
            allMovies = movieState.movies;
          } else {
            allMovies = context.read<MovieBloc>().currentMovies;
          }

          return BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, favState) {
              final List<String> favoriteIds = favState is FavoritesLoadedState ? favState.favoriteIds : [];
              
              // Filter film berdasarkan ID favorit terdaftar
              final favoriteMovies = allMovies.where((m) => favoriteIds.contains(m.id)).toList();

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
                        isFavorite: true,
                        onFavoriteToggle: () {
                          context.read<FavoriteBloc>().add(ToggleFavoriteEvent(movie.id));
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
