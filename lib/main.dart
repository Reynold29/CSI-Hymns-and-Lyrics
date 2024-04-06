import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/hymns_screen.dart';
import 'screens/keerthane_screen.dart';
import 'screens/settings_screen.dart';
import 'theme_state.dart';
import 'screens/changelog_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }
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
      title: const Text('CSI Kannada Hymns'),
      leading: Builder(
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
            child: Text('CSI Kannada and English Hymns and Lyrics'), 
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("What's New?"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangelogScreen()), // Navigate!
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Developer"),
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

