import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/search_results.dart';

void main() {
  runApp(const AirlineApp());
}

class AirlineApp extends StatelessWidget {
  const AirlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0B2545); // deep navy
    final accent = const Color(0xFFB6862E); // gold
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassicAir Booking',
      theme: ThemeData(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(primary: primary, secondary: accent),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        SearchResults.routeName: (context) => const SearchResults(),
      },
    );
  }
}
