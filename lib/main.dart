import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'bloc/movie_bloc.dart';
import 'bloc/favorite_bloc.dart';
import 'ui/pages/home.dart';

/// The main entry point of the Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Memuat konfigurasi environment (.env)
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Tetap berjalan jika file .env gagal dimuat (misalnya saat testing)
  }
  runApp(const MyApp());
}

/// The root widget of the application that sets up themes and provides the MovieBloc and FavoriteBloc globally.
class MyApp extends StatelessWidget {
  /// Constructor for MyApp.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MovieBloc(),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc()..add(LoadFavoritesEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Movie Catalog',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 42, 51, 146),
          ),
        ),
        home: const HomeScreen(title: 'Movie Catalog'),
      ),
    );
  }
}
