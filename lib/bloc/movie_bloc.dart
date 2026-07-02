import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

/// An abstract base class for all Movie events.
abstract class MovieEvent {}

/// An event triggered to fetch movies from the repository (reloads page 1).
class FetchMoviesEvent extends MovieEvent {}

/// An event triggered to fetch the next page of movies for pagination.
class FetchNextPageEvent extends MovieEvent {}

/// An event triggered to add a new custom movie.
class AddMovieEvent extends MovieEvent {
  final Movie movie;

  /// Constructor for AddMovieEvent.
  AddMovieEvent(this.movie);
}

/// An abstract base class for all Movie states.
abstract class MovieState {}

/// A state representing that the movies are currently being loaded.
class MovieLoadingState extends MovieState {}

/// A state representing that movies have been successfully loaded.
class MovieLoadedState extends MovieState {
  final List<Movie> movies;
  final int nextPage;
  final bool hasReachedMax;
  final bool isFetchingNextPage;
  
  /// Constructor for MovieLoadedState.
  MovieLoadedState(
    this.movies, {
    this.nextPage = 2,
    this.hasReachedMax = false,
    this.isFetchingNextPage = false,
  });

  /// Creates a copy of MovieLoadedState with specified fields replaced.
  MovieLoadedState copyWith({
    List<Movie>? movies,
    int? nextPage,
    bool? hasReachedMax,
    bool? isFetchingNextPage,
  }) {
    return MovieLoadedState(
      movies ?? this.movies,
      nextPage: nextPage ?? this.nextPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
    );
  }
}

/// A state representing that an error occurred while loading movies.
class MovieErrorState extends MovieState {
  final String message;
  final List<Movie> movies;
  
  /// Constructor for MovieErrorState.
  MovieErrorState(this.message, [this.movies = const []]);
}

/// The Business Logic Component (BLoC) that manages movie list loading and adding.
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository _repository = MovieRepository();
  List<Movie> _cachedMovies = [];

  /// A getter to access the most recently loaded list of movies synchronously.
  List<Movie> get currentMovies => _cachedMovies;

  /// Constructor for MovieBloc that initializes event handlers.
  MovieBloc() : super(MovieLoadingState()) {
    on<FetchMoviesEvent>(_onFetchMovies);
    on<FetchNextPageEvent>(_onFetchNextPage);
    on<AddMovieEvent>(_onAddMovie);
    
    add(FetchMoviesEvent());
  }

  /// Event handler for FetchMoviesEvent that calls the repository to load page 1.
  void _onFetchMovies(FetchMoviesEvent event, Emitter<MovieState> emit) async {
    emit(MovieLoadingState());
    try {
      _cachedMovies = await _repository.fetchMovies(page: 1);
      emit(MovieLoadedState(List.from(_cachedMovies), nextPage: 2, hasReachedMax: false, isFetchingNextPage: false));
    } on MovieFetchException catch (e) {
      _cachedMovies = e.fallbackMovies;
      emit(MovieErrorState(e.message, List.from(_cachedMovies)));
    } catch (e) {
      emit(MovieErrorState('Gagal mengambil data film: $e', List.from(_cachedMovies)));
    }
  }

  /// Event handler for FetchNextPageEvent to load additional pages.
  void _onFetchNextPage(FetchNextPageEvent event, Emitter<MovieState> emit) async {
    final currentState = state;
    if (currentState is MovieLoadedState) {
      // Mencegah duplikasi request jika sedang memuat atau sudah habis data
      if (currentState.hasReachedMax || currentState.isFetchingNextPage) return;

      emit(currentState.copyWith(isFetchingNextPage: true));

      try {
        final List<Movie> newMovies = await _repository.fetchMovies(page: currentState.nextPage);
        
        if (newMovies.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isFetchingNextPage: false));
        } else {
          _cachedMovies = [...currentState.movies, ...newMovies];
          emit(MovieLoadedState(
            List.from(_cachedMovies),
            nextPage: currentState.nextPage + 1,
            hasReachedMax: false,
            isFetchingNextPage: false,
          ));
        }
      } on MovieFetchException catch (e) {
        emit(MovieErrorState(e.message, List.from(_cachedMovies)));
        // Kembalikan ke LoadedState setelah jeda agar user bisa men-scroll lagi untuk mencoba ulang
        emit(currentState.copyWith(isFetchingNextPage: false));
      } catch (e) {
        emit(MovieErrorState('Gagal memuat halaman berikutnya: $e', List.from(_cachedMovies)));
        emit(currentState.copyWith(isFetchingNextPage: false));
      }
    }
  }

  /// Event handler for AddMovieEvent that saves the movie and refreshes the list from page 1.
  void _onAddMovie(AddMovieEvent event, Emitter<MovieState> emit) async {
    try {
      await _repository.saveCustomMovie(event.movie);
      _cachedMovies = await _repository.fetchMovies(page: 1);
      emit(MovieLoadedState(List.from(_cachedMovies), nextPage: 2, hasReachedMax: false, isFetchingNextPage: false));
    } on MovieFetchException catch (e) {
      _cachedMovies = e.fallbackMovies;
      emit(MovieErrorState(e.message, List.from(_cachedMovies)));
    } catch (e) {
      emit(MovieErrorState('Gagal menyimpan film kustom: $e', List.from(_cachedMovies)));
    }
  }
}
