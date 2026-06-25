import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/bloc/movie_bloc.dart';

void main() {
  group('MovieBloc Unit Tests', () {
    late MovieBloc movieBloc;

    setUp(() {
      movieBloc = MovieBloc();
    });

    tearDown(() {
      movieBloc.dispose();
    });

    test('Initial fetch emits MovieLoadingState then MovieLoadedState', () async {
      // Menguji urutan state yang dipancarkan stream saat inisialisasi
      expectLater(
        movieBloc.stateStream,
        emitsInOrder([
          isA<MovieLoadingState>(),
          isA<MovieLoadedState>(),
        ]),
      );
    });

    test('ToggleFavoriteEvent updates movie isFavorite status', () async {
      // Tunggu sampai data awal selesai dimuat (MovieLoadedState)
      await expectLater(
        movieBloc.stateStream,
        emitsThrough(isA<MovieLoadedState>()),
      );

      // Pastikan film pertama awalnya isFavorite == false
      final initialMovies = movieBloc.currentMovies;
      expect(initialMovies.isNotEmpty, true);
      final firstMovieId = initialMovies.first.id;
      expect(initialMovies.first.isFavorite, false);

      // Memicu ToggleFavoriteEvent untuk film pertama
      movieBloc.eventSink.add(ToggleFavoriteEvent(firstMovieId));

      // Memverifikasi state terbaru memiliki isFavorite == true
      final newState = await movieBloc.stateStream.firstWhere((state) => state is MovieLoadedState) as MovieLoadedState;
      final updatedMovie = newState.movies.firstWhere((m) => m.id == firstMovieId);
      expect(updatedMovie.isFavorite, true);
    });
  });
}
