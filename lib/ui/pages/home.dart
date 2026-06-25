import 'package:flutter/material.dart';
import '../../bloc/movie_bloc.dart';
import '../widgets/movie_card.dart';
import 'movie_details.dart';
import 'favorites.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Inisialisasi MovieBloc langsung pada deklarasi field agar aman dari Hot Reload
  final MovieBloc _movieBloc = MovieBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _movieBloc.dispose(); // Pastikan BLoC di-dispose saat widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              // Navigasi ke halaman FavoritesScreen dengan membawa _movieBloc
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(movieBloc: _movieBloc),
                ),
              );
            },
            tooltip: 'View Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Memicu event fetch ulang melalui BLoC
              _movieBloc.eventSink.add(FetchMoviesEvent());
            },
            tooltip: 'Refresh Movies',
          ),
        ],
      ),
      // MENGGUNAKAN STREAMBUILDER
      // StreamBuilder mendengarkan stateStream dari MovieBloc dan merender UI secara reaktif
      body: StreamBuilder<MovieState>(
        stream: _movieBloc.stateStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          final state = snapshot.data;

          if (state is MovieLoadingState || state == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat daftar film via StreamBuilder & BLoC...'),
                ],
              ),
            );
          } else if (state is MovieErrorState) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (state is MovieLoadedState) {
            final movies = state.movies;

            if (movies.isEmpty) {
              return const Center(child: Text('Tidak ada film tersedia.'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
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
                        // Kirim event ToggleFavoriteEvent ke dalam eventSink BLoC
                        _movieBloc.eventSink.add(ToggleFavoriteEvent(movie.id));
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
