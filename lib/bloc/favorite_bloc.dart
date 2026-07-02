import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An abstract base class for all Favorite events.
abstract class FavoriteEvent {}

/// An event triggered to load favorited movie IDs from Local Storage.
class LoadFavoritesEvent extends FavoriteEvent {}

/// An event triggered to add or remove a movie from favorites.
class ToggleFavoriteEvent extends FavoriteEvent {
  final String movieId;

  /// Constructor for ToggleFavoriteEvent.
  ToggleFavoriteEvent(this.movieId);
}

/// An abstract base class for all Favorite states.
abstract class FavoriteState {}

/// A state representing that favorite movies are currently being loaded.
class FavoritesLoadingState extends FavoriteState {}

/// A state representing that favorite movie IDs have been successfully loaded.
class FavoritesLoadedState extends FavoriteState {
  final List<String> favoriteIds;

  /// Constructor for FavoritesLoadedState.
  FavoritesLoadedState(this.favoriteIds);
}

/// The Business Logic Component (BLoC) that manages favorite status.
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  static const String _favoriteIdsKey = 'favorite_movie_ids';

  /// Constructor for FavoriteBloc.
  FavoriteBloc() : super(FavoritesLoadingState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  /// Event handler for LoadFavoritesEvent that reads favorites from SharedPreferences.
  void _onLoadFavorites(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoritesLoadingState());
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = prefs.getStringList(_favoriteIdsKey) ?? [];
    emit(FavoritesLoadedState(favoriteIds));
  }

  /// Event handler for ToggleFavoriteEvent that updates SharedPreferences.
  void _onToggleFavorite(ToggleFavoriteEvent event, Emitter<FavoriteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentIds = prefs.getStringList(_favoriteIdsKey) ?? [];

    if (currentIds.contains(event.movieId)) {
      currentIds.remove(event.movieId);
    } else {
      currentIds.add(event.movieId);
    }

    await prefs.setStringList(_favoriteIdsKey, currentIds);
    emit(FavoritesLoadedState(List.from(currentIds)));
  }
}
