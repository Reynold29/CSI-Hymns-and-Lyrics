import 'theme_state.dart';
import 'widgets/sidebar.dart';
import 'screens/hymns_screen.dart';
import 'screens/keerthane_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:hymns_latest/widgets/gesture_control.dart';
import 'package:hymns_latest/screens/favorites_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(
  ShowCaseWidget(
    builder: (context) => ChangeNotifierProvider(
      create: (context) => ThemeState(),
      child: const MyApp(),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  // ignore: unused_field
  int _counter = 0;
  final GlobalKey _menuButtonKey = GlobalKey();
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  late AnimationController _animationController;
  late PageController _pageController;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300),
    ); 
    _pageController = PageController();
    _getThemeFromPreferences();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          update();
        }
      });
    }).catchError((e) {
      //---print(e.toString());---//
    });
  }

  void update() async {
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
    });
  }

  void _incrementCounter() {
    setState(() {
    _counter++;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
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
    const FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    //---print('Tapped index: $index');---//
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _getThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _checkFirstRunAndShowCase() async { 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = (prefs.getBool('isFirstRun') ?? true);

    if (isFirstRun) {
      Future.delayed(const Duration(seconds: 1), () => 
        ShowCaseWidget.of(context).startShowCase([ _menuButtonKey ])
      );
      prefs.setBool('isFirstRun', false);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('CSI Kannada Hymns Book',
      style: TextStyle(fontFamily: 'plusJakartaSans', fontWeight: FontWeight.bold),
      ), 
      leading: Builder(
        builder: (context) {
          return Showcase(
            key: _menuButtonKey,
            title: 'Sidebar',
            description: 'Tap here to open the menu for categories and settings.',
            targetShapeBorder: const CircleBorder(),
            overlayColor: const Color.fromARGB(139, 0, 0, 0).withOpacity(0.6),  
            titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
    ),
      drawer: Sidebar(animationController: _animationController),
      body: GestureControl( 
        child: PageView( 
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _screens, 
        ),
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); 
        }, 
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: _themeMode == ThemeMode.dark ? Colors.white : const Color.fromARGB(107, 178, 178, 178), 
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
        ),
        child: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.music_note_outlined), 
              label: 'Hymns',
              selectedIcon: Container( 
                margin: const EdgeInsets.only(bottom: 6.0),
                child: const Icon(Icons.music_note_outlined),
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.library_music_outlined),
              label: 'Keerthane',
              selectedIcon: Container( 
                margin: const EdgeInsets.only(bottom: 6.0),
                child: const Icon(Icons.library_music_outlined),
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border_outlined),
              label: 'Favorites',
              selectedIcon: Container( 
                margin: const EdgeInsets.only(bottom: 6.0),
                child: const Icon(Icons.favorite_border_outlined),
              ),
            ), 
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
        )
      ),
    );
  }
}
