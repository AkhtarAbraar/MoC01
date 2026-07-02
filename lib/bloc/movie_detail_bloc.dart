import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/movie_repository.dart';

/// An abstract base class for all Movie Detail events.
abstract class MovieDetailEvent {}

/// An event triggered to fetch details for a specific movie.
class FetchMovieDetailsEvent extends MovieDetailEvent {
  final String movieId;

  /// Constructor for FetchMovieDetailsEvent.
  FetchMovieDetailsEvent(this.movieId);
}

/// An abstract base class for all Movie Detail states.
abstract class MovieDetailState {}

/// A state representing that movie details are currently being loaded.
class MovieDetailLoadingState extends MovieDetailState {}

/// A state representing that movie details have been successfully loaded.
class MovieDetailLoadedState extends MovieDetailState {
  final Map<String, dynamic> details;

  /// Constructor for MovieDetailLoadedState.
  MovieDetailLoadedState(this.details);
}

/// A state representing that an error occurred while loading movie details.
class MovieDetailErrorState extends MovieDetailState {
  final String message;

  /// Constructor for MovieDetailErrorState.
  MovieDetailErrorState(this.message);
}

/// The Business Logic Component (BLoC) that manages movie details.
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepository _repository = MovieRepository();

  /// Constructor for MovieDetailBloc.
  MovieDetailBloc() : super(MovieDetailLoadingState()) {
    on<FetchMovieDetailsEvent>(_onFetchMovieDetails);
  }

  /// Event handler for FetchMovieDetailsEvent that calls the repository.
  void _onFetchMovieDetails(FetchMovieDetailsEvent event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoadingState());
    try {
      final details = await _repository.fetchMovieDetails(event.movieId);
      emit(MovieDetailLoadedState(details));
    } catch (e) {
      emit(MovieDetailErrorState('Gagal mengambil detail film: $e'));
    }
  }
}
