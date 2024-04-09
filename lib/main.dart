import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
import 'theme_state.dart';
import 'screens/hymns_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/keerthane_screen.dart';  
import 'screens/changelog_screen.dart';
import 'screens/about_developer_screen.dart';

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

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;

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
        child: Column(
          children: [
            Expanded( // Make the scrollable portion take up available space
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    // Top Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: const Column( // Wrap title and divider in a Column
                        children: [
                          Text(
                            'CSI Hymns and Lyrics',
                            style: TextStyle(
                              fontSize: 22,
                              height: 5.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Example color change
                            ),
                          ),
                          Divider( // Add the divider line
                            height: 15.0, // Adjust divider height as needed
                            thickness: 1.0, // Adjust divider thickness as needed
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: const Row(
                        children: [
                          Icon(Icons.category),
                          SizedBox(width: 8.0),
                          Text(
                            'Categories',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Flexible( 
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length, 
                        itemBuilder: (context, index) {
                          return Padding( 
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: ListTile(
                              leading: const Icon(Icons.library_books),
                              title: Text(categories[index]),
                              onTap: (){
                                // ... Your category tap functionality
                              },
                            )
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Static Bottom Block (Outside the scrollable area)
            Container(
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings), 
                    title: const Text("Settings"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()), 
                      );
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.update), 
                    title: const Text("What's New?"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangelogScreen()), 
                      );
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.info), 
                    title: const Text("About Developer"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutDeveloper()), 
                      );
                    }
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
