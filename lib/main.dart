import 'package:flutter/material.dart';
import 'screens/hymns_screen.dart';
import 'screens/keerthane_screen.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSI Hymns and Lyrics',
      theme: ThemeData.light(), // Start with light theme
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Start with system default
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 
  ThemeMode _themeMode = ThemeMode.system; 

  static final List<Widget> _screens = [
    HymnsScreen(),
    const KeerthaneScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getThemeFromPreferences(); 
  }

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
      title: const Text('Hymns App'),
      leading: Builder( // Add this Builder
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(), 
          );
        },
      ),
    ),
    drawer: Drawer( 
      child: ListView( 
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader( 
            decoration: BoxDecoration(
              color: Colors.blue, 
            ),
            child: Text('Hymns App'), 
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Developer'),
            onTap: () {
              // Handle navigation or action when tapped
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("What's New?"),
            onTap: () {
              // Handle navigation or action when tapped
            },
          ),
        ],
      ),
    ),
      body: _screens[_selectedIndex], 
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: _themeMode == ThemeMode.dark ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(107, 178, 178, 178),  // Adjust colors as needed
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        child: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Hymns'),
            NavigationDestination(icon: Icon(Icons.music_note_outlined), label: 'Keerthane'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
        ),
      ),
    );
  }
}

