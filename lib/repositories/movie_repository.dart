import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

/// Exception thrown when movie fetching fails, holding a user-friendly error message and fallback data.
class MovieFetchException implements Exception {
  final String message;
  final List<Movie> fallbackMovies;

  /// Constructor for MovieFetchException.
  MovieFetchException(this.message, this.fallbackMovies);

  @override
  String toString() => message;
}

/// A repository class that handles API data fetching and Local Storage caching logic.
class MovieRepository {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _cacheKey = 'cached_movies';
  static const String _customMoviesKey = 'custom_movies';
  final Dio _dio = Dio();

  /// Fetches a list of movies from the API (plus local custom movies) or falls back to Local Storage if offline.
  Future<List<Movie>> fetchMovies({int page = 1}) async {
    final List<Movie> customMovies = await getCustomMovies();
    String apiKey = '';
    String bearerToken = '';
    try {
      apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
      bearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';
    } catch (_) {}

    // Jika API Key dan Bearer Token kosong, gunakan fallback data cache lokal
    if (bearerToken.isEmpty && (apiKey.isEmpty || apiKey == 'YOUR_TMDB_API_KEY_HERE')) {
      final List<Movie> cachedApiMovies = await _getMoviesFromLocal();
      return [...customMovies, ...cachedApiMovies];
    }

    try {
      final Map<String, dynamic> queryParams = {
        'language': 'id-ID',
        'page': page,
      };

      Options? options;
      // Gunakan Bearer Token jika tersedia (Lebih modern dan aman)
      if (bearerToken.isNotEmpty && bearerToken != 'YOUR_TMDB_BEARER_TOKEN_HERE') {
        options = Options(headers: {
          'Authorization': 'Bearer $bearerToken',
          'accept': 'application/json',
        });
      } else {
        // Fallback ke Query Parameter API Key jika Bearer Token tidak diset
        queryParams['api_key'] = apiKey;
      }

      // 1. Integrasi API TMDB menggunakan Dio dengan parameter halaman (page)
      final response = await _dio.get(
        '$_baseUrl/movie/popular',
        queryParameters: queryParams,
        options: options,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] ?? [];
        final List<Movie> apiMovies = results.map((json) => Movie.fromJson(json)).toList();

        // 2. Simpan cache data API secara lokal untuk Fallback Plan (Hanya untuk halaman pertama)
        if (page == 1) {
          await _saveMoviesToLocal(apiMovies);
        }
        
        return page == 1 ? [...customMovies, ...apiMovies] : apiMovies;
      } else {
        throw Exception('Gagal memuat film dari TMDB API: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      // Tangani error Dio, parse pesan error dan kembalikan beserta data offline cache
      final String readableError = _handleDioError(dioError);
      final List<Movie> cachedApiMovies = await _getMoviesFromLocal();
      throw MovieFetchException(readableError, [...customMovies, ...cachedApiMovies]);
    } catch (e) {
      final List<Movie> cachedApiMovies = await _getMoviesFromLocal();
      throw MovieFetchException('Terjadi kesalahan tidak terduga: $e', [...customMovies, ...cachedApiMovies]);
    }
  }

  /// Formats DioException into a user-friendly error message in Indonesian.
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke server habis (Connection Timeout). Periksa koneksi internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Koneksi pengiriman data habis (Send Timeout). Silakan coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Koneksi penerimaan data habis (Receive Timeout). Server lambat merespons.';
      case DioExceptionType.badResponse:
        final int? statusCode = error.response?.statusCode;
        // Ambil status_message resmi dari JSON respons TMDB jika ada
        final String remoteMessage = error.response?.data?['status_message'] ?? '';
        final String finalMessage = remoteMessage.isNotEmpty ? remoteMessage : (error.response?.statusMessage ?? 'Unknown error');
        return 'Error HTTP $statusCode: $finalMessage';
      case DioExceptionType.cancel:
        return 'Permintaan ke server dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Koneksi internet terputus (Offline). Mengalihkan ke mode lokal.';
      default:
        return 'Terjadi kesalahan jaringan: ${error.message}';
    }
  }

  /// Saves the list of API-fetched movies to Local Storage as a JSON string.
  Future<void> _saveMoviesToLocal(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(movies.map((m) => m.toJson()).toList());
    await prefs.setString(_cacheKey, jsonString);
  }

  /// Retrieves the cached list of API movies from Local Storage during fallback.
  Future<List<Movie>> _getMoviesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_cacheKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Movie.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  /// Saves a user-added custom movie to Local Storage.
  Future<void> saveCustomMovie(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Movie> existingCustom = await getCustomMovies();
    existingCustom.insert(0, movie);
    final String jsonString = jsonEncode(existingCustom.map((m) => m.toJson()).toList());
    await prefs.setString(_customMoviesKey, jsonString);
  }

  /// Retrieves user-added custom movies from Local Storage.
  Future<List<Movie>> getCustomMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_customMoviesKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Movie.fromJson(json)).toList();
    }
    return [];
  }

  /// Fetches actual movie details (Director and Reviews) from TMDB or returns simulated ones for custom movies.
  Future<Map<String, dynamic>> fetchMovieDetails(String movieId) async {
    // Jika ID film kustom (bukan angka), gunakan data simulasi lokal
    if (int.tryParse(movieId) == null) {
      return {
        'director': 'Pembuat Film Kustom',
        'reviews': [
          {'reviewer': 'System', 'comment': 'Ini adalah film kustom lokal.', 'score': '10/10'},
        ],
      };
    }

    String apiKey = '';
    String bearerToken = '';
    try {
      apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
      bearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';
    } catch (_) {}

    if (bearerToken.isEmpty && (apiKey.isEmpty || apiKey == 'YOUR_TMDB_API_KEY_HERE')) {
      throw Exception('Konfigurasi TMDB_API_KEY atau TMDB_BEARER_TOKEN tidak ditemukan.');
    }

    try {
      final Map<String, dynamic> queryParams = {};
      Options? options;

      if (bearerToken.isNotEmpty && bearerToken != 'YOUR_TMDB_BEARER_TOKEN_HERE') {
        options = Options(headers: {
          'Authorization': 'Bearer $bearerToken',
          'accept': 'application/json',
        });
      } else {
        queryParams['api_key'] = apiKey;
      }

      // Ambil nama sutradara dari TMDB Credits API
      final creditsResponse = await _dio.get(
        '$_baseUrl/movie/$movieId/credits',
        queryParameters: queryParams,
        options: options,
      );

      String director = 'Unknown';
      if (creditsResponse.statusCode == 200) {
        final List<dynamic> crew = creditsResponse.data['crew'] ?? [];
        final directorData = crew.firstWhere(
          (member) => member['job'] == 'Director',
          orElse: () => null,
        );
        if (directorData != null) {
          director = directorData['name'];
        }
      }

      // Ambil review dari TMDB Reviews API
      final reviewsResponse = await _dio.get(
        '$_baseUrl/movie/$movieId/reviews',
        queryParameters: queryParams,
        options: options,
      );

      final List<dynamic> reviewsList = [];
      if (reviewsResponse.statusCode == 200) {
        final List<dynamic> results = reviewsResponse.data['results'] ?? [];
        for (var i = 0; i < results.length && i < 2; i++) {
          final rating = results[i]['author_details']?['rating'];
          reviewsList.add({
            'reviewer': results[i]['author'] ?? 'Anonim',
            'comment': results[i]['content'] ?? '',
            'score': rating != null ? '$rating/10' : 'N/A',
          });
        }
      }

      if (reviewsList.isEmpty) {
        reviewsList.add({
          'reviewer': 'System',
          'comment': 'Belum ada ulasan untuk film ini di TMDB.',
          'score': 'N/A',
        });
      }

      return {
        'director': director,
        'reviews': reviewsList,
      };
    } on DioException catch (dioError) {
      throw Exception(_handleDioError(dioError));
    } catch (e) {
      throw Exception('Gagal memuat ulasan: $e');
    }
  }
}
