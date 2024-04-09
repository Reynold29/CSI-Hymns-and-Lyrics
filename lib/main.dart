import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';
import 'screens/hymns_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/keerthane_screen.dart';
import 'widgets/sidebar.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => ThemeState(),
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static BuildContext of(BuildContext context) {
    return context;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeState>(
      builder: (context, themeState, child) {
        return MaterialApp(
          title: 'CSI Hymns and Lyrics',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeState.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  late AnimationController _animationController;

  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), 
    );
    _getThemeFromPreferences();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen; 
      if (_isDrawerOpen) {
        _animationController.forward(); 
      } else {
        _animationController.reverse(); 
      }
    });
  }

  static final List<Widget> _screens = [
    const HymnsScreen(),
    const KeerthaneScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> categories = [
    "Jesus' Birth",
    "Jesus' Passion and Death",
    "Jesus' Resurrection",
    "Jesus' Ascension and His Kingdom",
    "Jesus' Coming Again",
    "New Year Songs",
    "Marriage Songs",
    "Birthday Songs",
    "Prayer for House Warming",
    "Prayer for Travelling",
    "Prayer for Rain",
    "Prayer in Trouble Times",
    "Prayer for Healing Sickness",
    "Prayer before Food",
  ];

  void _getThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSI  Kannada  Hymns',
        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'plusJakartaSans'),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () { 
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Sidebar(animationController: _animationController),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: _themeMode == ThemeMode.dark ? Colors.white : const Color.fromARGB(107, 178, 178, 178), 
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
        ),
        child: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.music_note_outlined), label: 'Hymns'),
            NavigationDestination(icon: Icon(Icons.library_music_outlined), label: 'Keerthane'),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
        ),
      ),
    );
  }
}


