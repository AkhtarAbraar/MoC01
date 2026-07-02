/// A data model representing a single Movie.
class Movie {
  final String id;
  final String title;
  final String genre;
  final String desc;
  final String year;
  final String rating;
  final String imageUrl;
  final bool isFavorite;

  /// Constructor for the Movie model.
  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.desc,
    required this.year,
    required this.rating,
    required this.imageUrl,
    this.isFavorite = false,
  });

  /// Factory method to parse JSON into a Movie object from TMDB API or Local Storage.
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Deteksi jika JSON berasal dari respon API TMDB
    if (json.containsKey('poster_path') || json.containsKey('vote_average') || json.containsKey('genre_ids')) {
      final double vote = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
      final String relDate = json['release_date']?.toString() ?? '';
      final String yearOnly = relDate.isNotEmpty ? relDate.split('-').first : 'N/A';
      final String posterPath = json['poster_path']?.toString() ?? '';
      final String fullImageUrl = posterPath.isNotEmpty 
          ? 'https://image.tmdb.org/t/p/w500$posterPath' 
          : '';
      
      // Pemetaan ID genre dari TMDB menjadi teks nama genre
      final List<dynamic> genreIds = json['genre_ids'] ?? [];
      final List<String> genreNames = genreIds.map((id) => _mapGenreIdToName(id as int)).toList();
      final String genresString = genreNames.isNotEmpty ? genreNames.join(', ') : 'General';

      return Movie(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? 'Unknown',
        genre: genresString,
        desc: json['overview'] ?? 'No description available',
        year: yearOnly,
        rating: vote.toStringAsFixed(1),
        imageUrl: fullImageUrl,
        isFavorite: false,
      );
    }

    // Default parser untuk cache lokal atau data film kustom
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown',
      genre: json['genre'] is List ? (json['genre'] as List).join(', ') : json['genre']?.toString() ?? '',
      desc: json['plot'] ?? json['desc'] ?? 'No description',
      year: json['year']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      imageUrl: json['poster'] ?? json['imageUrl'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// Converts the Movie object back into a JSON Map for saving to Local Storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'desc': desc,
      'year': year,
      'rating': rating,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  /// Creates a copy of the current Movie with specified fields replaced, maintaining immutability.
  Movie copyWith({
    String? id,
    String? title,
    String? genre,
    String? desc,
    String? year,
    String? rating,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      desc: desc ?? this.desc,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Helper untuk memetakan ID Genre TMDB ke String teks nama genre.
  static String _mapGenreIdToName(int id) {
    const Map<int, String> genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return genreMap[id] ?? 'Other';
  }
}
