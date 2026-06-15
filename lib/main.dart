import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TvParaguayApp());
}

class TvParaguayApp extends StatelessWidget {
  const TvParaguayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Paraguay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}