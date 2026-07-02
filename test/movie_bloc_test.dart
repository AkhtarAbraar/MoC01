import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/bloc/movie_bloc.dart';
import 'package:flutter_application_1/bloc/favorite_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MovieBloc Unit Tests (flutter_bloc)', () {
    late MovieBloc movieBloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'cached_movies': jsonEncode([
          {
            'id': '1',
            'title': 'Mock Movie 1',
            'genre': 'Action',
            'desc': 'A great mock movie',
            'year': '2024',
            'rating': '8.5',
            'imageUrl': 'https://example.com/image.jpg',
            'isFavorite': false
          }
        ])
      });
      movieBloc = MovieBloc();
    });

    tearDown(() {
      movieBloc.close();
    });

    test('Initial state is MovieLoadingState', () {
      expect(movieBloc.state, isA<MovieLoadingState>());
    });

    test('Initial fetch eventually emits MovieLoadedState', () async {
      await expectLater(
        movieBloc.stream,
        emitsThrough(isA<MovieLoadedState>()),
      );
    });
  });

  group('FavoriteBloc Unit Tests', () {
    late FavoriteBloc favoriteBloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'favorite_movie_ids': ['1', '2']
      });
      favoriteBloc = FavoriteBloc();
    });

    tearDown(() {
      favoriteBloc.close();
    });

    test('Initial state is FavoritesLoadingState', () {
      expect(favoriteBloc.state, isA<FavoritesLoadingState>());
    });

    test('LoadFavoritesEvent emits FavoritesLoadedState with cached IDs', () async {
      favoriteBloc.add(LoadFavoritesEvent());
      await expectLater(
        favoriteBloc.stream,
        emitsInOrder([
          isA<FavoritesLoadingState>(),
          isA<FavoritesLoadedState>().having((state) => state.favoriteIds, 'favoriteIds', ['1', '2']),
        ]),
      );
    });

    test('ToggleFavoriteEvent adds/removes favorite IDs', () async {
      favoriteBloc.add(LoadFavoritesEvent());
      await favoriteBloc.stream.firstWhere((state) => state is FavoritesLoadedState);

      // Tambahkan ID '3'
      favoriteBloc.add(ToggleFavoriteEvent('3'));
      var state = await favoriteBloc.stream.firstWhere((s) => s is FavoritesLoadedState) as FavoritesLoadedState;
      expect(state.favoriteIds, contains('3'));

      // Hapus ID '1'
      favoriteBloc.add(ToggleFavoriteEvent('1'));
      state = await favoriteBloc.stream.firstWhere((s) => s is FavoritesLoadedState) as FavoritesLoadedState;
      expect(state.favoriteIds, isNot(contains('1')));
    });
  });
}
