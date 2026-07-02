import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/movie_bloc.dart';
import '../../bloc/favorite_bloc.dart';
import '../../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_details.dart';
import 'favorites.dart';

/// The main screen that fetches and displays the list of all movies from the API or Local Storage with infinite scroll.
class HomeScreen extends StatefulWidget {
  final String title;

  /// Constructor for HomeScreen.
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Triggers a fetch event for the next page when the user scrolls near the bottom.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieBloc>().add(FetchNextPageEvent());
    }
  }

  /// Displays a modal popup form to add a new movie to Local Storage.
  void _showAddMovieDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final genreController = TextEditingController();
    final descController = TextEditingController();
    final yearController = TextEditingController();
    final ratingController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Film Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul Film'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: genreController,
                    decoration: const InputDecoration(labelText: 'Genre (contoh: Action, Drama)'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Genre tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi / Sinopsis'),
                    maxLines: 3,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Tahun Rilis'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Tahun tidak boleh kosong';
                      if (int.tryParse(value) == null) return 'Tahun harus berupa angka';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: ratingController,
                    decoration: const InputDecoration(labelText: 'Rating (contoh: 8.5)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Rating tidak boleh kosong';
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed < 0.0 || parsed > 10.0) {
                        return 'Rating harus berupa angka 0.0 - 10.0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Gambar Poster (Opsional)',
                      hintText: 'Biarkan kosong untuk default',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Fallback poster jika user mengosongkan URL gambar
                  const String defaultUrl = 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1000&auto=format&fit=cover';
                  final String finalUrl = imageUrlController.text.trim().isEmpty ? defaultUrl : imageUrlController.text.trim();

                  final newMovie = Movie(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    genre: genreController.text.trim(),
                    desc: descController.text.trim(),
                    year: yearController.text.trim(),
                    rating: ratingController.text.trim(),
                    imageUrl: finalUrl,
                    isFavorite: false,
                  );

                  // Kirim event AddMovieEvent ke BLoC
                  context.read<MovieBloc>().add(AddMovieEvent(newMovie));

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Film "${newMovie.title}" berhasil ditambahkan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  /// Helper widget to build the reactive ListView of movies.
  Widget _buildMovieListView(BuildContext context, List<Movie> movies, {bool isFetchingNextPage = false}) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favState) {
        final List<String> favoriteIds = favState is FavoritesLoadedState ? favState.favoriteIds : [];
        // Jika sedang loading halaman berikutnya, tambahkan 1 item di paling bawah untuk progress indicator
        final int itemCount = isFetchingNextPage ? movies.length + 1 : movies.length;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Jika index menyentuh item ekstra paling akhir, tampilkan CircularProgressIndicator
              if (index == movies.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final movie = movies[index];
              final isFav = favoriteIds.contains(movie.id);

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
                  isFavorite: isFav,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            tooltip: 'View Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MovieBloc>().add(FetchMoviesEvent());
            },
            tooltip: 'Refresh Movies',
          ),
        ],
      ),
      body: BlocListener<MovieBloc, MovieState>(
        listener: (context, state) {
          // Tampilkan snackbar pop-up jika terjadi error jaringan / HTTP dari Dio
          if (state is MovieErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoadingState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat daftar film dari TMDB...'),
                  ],
                ),
              );
            } else if (state is MovieErrorState) {
              final movies = state.movies;

              if (movies.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              }

              // Jika terjadi error saat scrolling tapi sudah ada film, tampilkan film cache lokal
              return _buildMovieListView(context, movies, isFetchingNextPage: false);
            } else if (state is MovieLoadedState) {
              final movies = state.movies;

              if (movies.isEmpty) {
                return const Center(child: Text('Tidak ada film tersedia.'));
              }

              return _buildMovieListView(
                context, 
                movies, 
                isFetchingNextPage: state.isFetchingNextPage,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(context),
        tooltip: 'Tambah Film',
        child: const Icon(Icons.add),
      ),
    );
  }
}
