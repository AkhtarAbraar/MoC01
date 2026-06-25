import '../models/movie.dart';

class MovieRepository {
  // Simulasi fetch data dari API / Database lokal menggunakan Future
  Future<List<Movie>> fetchMovies() async {
    // Simulasi delay jaringan (network delay) selama 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));

    return [
      Movie(
        id: '1',
        title: 'Transformers: The Last Knight',
        genre: 'Action',
        desc: 'A deadly threat from Earth\'s history reappears and a hunt for a lost artifact takes place between Autobots and Decepticons.',
        year: '2017',
        rating: '5.2',
        imageUrl: 'https://m.media-amazon.com/images/M/MV5BYWNlNjU3ZTItYTY3Mi00YTU1LTk4NjQtYjQ3MjFiNjcyODliXkEyXkFqcGc@._V1_.jpg',
      ),
      Movie(
        id: '2',
        title: 'The Dark Knight',
        genre: 'Action',
        desc: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        year: '2008',
        rating: '9.0',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/The_Dark_Knight_%282008_film%29.jpg/250px-The_Dark_Knight_%282008_film%29.jpg',
      ),
      Movie(
        id: '3',
        title: 'Gundam: Hathaway',
        genre: 'Sci-Fi',
        desc: 'A young pilot named Hathaway is caught in the middle of a conflict between the Earth Federation and a terrorist group calling themselves Mafty.',
        year: '2021',
        rating: '7.5',
        imageUrl: 'https://m.media-amazon.com/images/M/MV5BYjdmOTI5ZmQtOTBiOS00YmIwLWJjMDMtMWQ5MDk3YTQyYTI5XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
      ),
      Movie(
        id: '4',
        title: 'The Nun',
        genre: 'Horror',
        desc: 'A young nun is possessed by a demonic entity in a cloistered abbey in Romania, forcing a priest and a novitiate to investigate the unholy dark secret.',
        year: '2018',
        rating: '5.3',
        imageUrl: 'https://m.media-amazon.com/images/M/MV5BMjM3NzQ5NDcxOF5BMl5BanBnXkFtZTgwNzM4MTQ5NTM@._V1_.jpg',
      ),
      Movie(
        id: '5',
        title: 'Merah Putih: One For All',
        genre: 'Drama',
        desc: 'Eight diverse kids form "Tim Merah Putih" to guard Indonesia\'s flag and defend their homeland values against all odds.',
        year: '2025',
        rating: '8.5',
        imageUrl: 'https://m.media-amazon.com/images/M/MV5BMDk5YTJlMjktOWQxNS00ZTZiLTgxYWUtMTI0M2VkNGU0MjZlXkEyXkFqcGc@._V1_QL75_UY281_CR4,0,190,281_.jpg',
      ),
    ];
  }

  // Simulasi fetch detail tambahan (seperti review/sinopsis lengkap) untuk mendemonstrasikan FutureBuilder di halaman detail
  Future<Map<String, dynamic>> fetchMovieDetails(String movieId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'director': movieId == '2' ? 'Christopher Nolan' : 'Famous Director',
      'reviews': [
        {'reviewer': 'Budi', 'comment': 'Film yang sangat epik dan layak ditonton!', 'score': '9/10'},
        {'reviewer': 'Siti', 'comment': 'Visualnya memukau, tapi alurnya agak cepat.', 'score': '8/10'},
      ],
    };
  }
}
