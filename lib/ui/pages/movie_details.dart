import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie.dart';
import '../../../bloc/movie_detail_bloc.dart';

/// A screen displaying the full details and reviews of a specific movie.
class MovieDetail extends StatelessWidget {
  final Movie movie;

  /// Constructor for MovieDetail.
  const MovieDetail({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailBloc()..add(FetchMovieDetailsEvent(movie.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(movie.title),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: BlocListener<MovieDetailBloc, MovieDetailState>(
          listener: (context, state) {
            // Tampilkan pop-up snackbar jika terjadi error jaringan saat mengambil detail film/ulasan
            if (state is MovieDetailErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  movie.imageUrl,
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
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${movie.year} • ${movie.genre}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(movie.desc, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    'Informasi Tambahan & Ulasan (MovieDetailBloc)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<MovieDetailBloc, MovieDetailState>(
                    builder: (context, state) {
                      if (state is MovieDetailLoadingState) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Memuat ulasan via MovieDetailBloc...'),
                              ],
                            ),
                          ),
                        );
                      } else if (state is MovieDetailErrorState) {
                        return Text(
                          'Gagal memuat ulasan: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (state is MovieDetailLoadedState) {
                        final data = state.details;
                        final reviews = data['reviews'] as List<dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sutradara: ${data['director']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ulasan Pengguna:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...reviews.map((rev) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(rev['reviewer']),
                                subtitle: Text(rev['comment']),
                                trailing: Text(
                                  rev['score'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                              ),
                            )),
                          ],
                        );
                      }
                      return const Text('Tidak ada ulasan tersedia.');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}
