import 'package:flutter/material.dart';
import '../../../models/movie.dart';
import '../../../repositories/movie_repository.dart';

class MovieDetail extends StatelessWidget {
  final Movie movie;

  const MovieDetail({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final repository = MovieRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Hero Image
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
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meta Info Row
                  Row(
                    children: [
                      Text(
                        '${movie.year} • ${movie.genre}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const Spacer(),
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

                  // Description
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(movie.desc, style: const TextStyle(fontSize: 16, height: 1.5)),

                  const Divider(height: 32, thickness: 1),

                  const Text(
                    'Informasi Tambahan & Ulasan (FutureBuilder)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // MENGGUNAKAN FUTUREBUILDER
                  // FutureBuilder memuat data asinkron (sekali jalan) dari MovieRepository
                  FutureBuilder<Map<String, dynamic>>(
                    future: repository.fetchMovieDetails(movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Memuat ulasan via FutureBuilder...'),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Gagal memuat ulasan: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
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
    );
  }
}
