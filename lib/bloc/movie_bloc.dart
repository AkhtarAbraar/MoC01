import 'dart:async';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

// Event untuk BLoC
abstract class MovieEvent {}

class FetchMoviesEvent extends MovieEvent {}

class ToggleFavoriteEvent extends MovieEvent {
  final String movieId;
  ToggleFavoriteEvent(this.movieId);
}

// State untuk BLoC
abstract class MovieState {}

class MovieLoadingState extends MovieState {}

class MovieLoadedState extends MovieState {
  final List<Movie> movies;
  MovieLoadedState(this.movies);
}

class MovieErrorState extends MovieState {
  final String message;
  MovieErrorState(this.message);
}

// Implementasi BLoC (Business Logic Component) murni menggunakan Stream & Sink
class MovieBloc {
  final MovieRepository _repository = MovieRepository();
  List<Movie> _cachedMovies = [];

  // Mendapatkan data film saat ini secara sinkron untuk initialData StreamBuilder
  List<Movie> get currentMovies => _cachedMovies;

  // StreamController untuk mengatur Input (Event)
  final _eventController = StreamController<MovieEvent>();
  Sink<MovieEvent> get eventSink => _eventController.sink;

  // StreamController untuk mengatur Output (State)
  final _stateController = StreamController<MovieState>.broadcast();
  Stream<MovieState> get stateStream => _stateController.stream;

  MovieBloc() {
    // Mendengarkan setiap event yang masuk melalui eventSink
    _eventController.stream.listen(_mapEventToState);
    
    // Trigger fetch data pertama kali saat BLoC diinisialisasi
    eventSink.add(FetchMoviesEvent());
  }

  void _mapEventToState(MovieEvent event) async {
    if (event is FetchMoviesEvent) {
      _stateController.sink.add(MovieLoadingState());
      try {
        _cachedMovies = await _repository.fetchMovies();
        _stateController.sink.add(MovieLoadedState(_cachedMovies));
      } catch (e) {
        _stateController.sink.add(MovieErrorState('Gagal mengambil data film: $e'));
      }
    } else if (event is ToggleFavoriteEvent) {
      // Ubah status isFavorite pada movie yang dipilih
      _cachedMovies = _cachedMovies.map((movie) {
        if (movie.id == event.movieId) {
          return movie.copyWith(isFavorite: !movie.isFavorite);
        }
        return movie;
      }).toList();

      // Kirim state baru yang sudah diperbarui ke UI melalui Stream
      _stateController.sink.add(MovieLoadedState(_cachedMovies));
    }
  }

  // Jangan lupa menutup stream controller untuk mencegah memory leak
  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}
