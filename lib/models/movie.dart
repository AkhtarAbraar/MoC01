class Movie {
  final String id;
  final String title;
  final String genre;
  final String desc;
  final String year;
  final String rating;
  final String imageUrl;
  final bool isFavorite;

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
}
