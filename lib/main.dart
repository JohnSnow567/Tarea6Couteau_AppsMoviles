import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/agify.dart';
import 'screens/genderize.dart';
import 'screens/universities.dart';
import 'screens/weather.dart';
import 'screens/pokemon.dart';
import 'screens/wordpress.dart';
import 'screens/about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarea 6 - Couteau',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    GenderPage(),
    AgePage(),
    UniversitiesPage(),
    WeatherPage(),
    PokemonPage(),
    WordpressNewsPage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarea 6 - Couteau'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'Genero'),
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: 'Edad'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Universidades'),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'Clima RD'),
          BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: 'Pokemon'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'WP Noticias'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Acerca de'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}