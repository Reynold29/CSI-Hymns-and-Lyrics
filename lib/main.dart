import 'dart:convert';
import 'theme_state.dart';
import 'widgets/sidebar.dart';
import 'screens/categories.dart';
import 'screens/hymns_screen.dart';
import 'screens/keerthane_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:hymns_latest/widgets/gesture_control.dart';
import 'package:hymns_latest/screens/favorites_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      FirebaseOptions firebaseOptions = const FirebaseOptions(
        apiKey: "AIzaSyDxevY9bYbwnMKCCyAqCXo5emtBbE4_keY",
        authDomain: "hymnappnoti.firebaseapp.com",
        projectId: "hymnappnoti",
        storageBucket: "hymnappnoti.firebasestorage.app",
        messagingSenderId: "162340486626",
        appId: "1:162340486626:web:6ea1b8331cdcb4b3e54dbb",
      );
      await Firebase.initializeApp(options: firebaseOptions);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue app initialization even if Firebase fails
  }

  await _initOneSignal();

  runApp(
    ShowCaseWidget(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => ThemeState(),
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _initOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("29f2a6ba-3f56-4ffe-8075-3b70d7440b13");
  OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeState>(
      builder: (context, themeState, child) {
        return MaterialApp(
          title: 'CSI Hymns and Lyrics',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeState.seedColor,
              brightness: Brightness.light,
            ),
            navigationBarTheme: NavigationBarThemeData(
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: themeState.blackThemeEnabled ? Colors.black : null,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeState.seedColor,
              brightness: Brightness.dark,
            ),
            navigationBarTheme: NavigationBarThemeData(
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
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
  late AnimationController _animationController;
  late PageController _pageController;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300),);
    _pageController = PageController();
    checkForUpdate();
    _initOneSignal();
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
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {});
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("29f2a6ba-3f56-4ffe-8075-3b70d7440b13");

    // -- iOS settings --
    OneSignal.Notifications.requestPermission(true);

    // -- Android settings --
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print("FOREGROUND WILL DISPLAY LISTENER: Notification Received");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER: ${jsonEncode(event.notification.jsonRepresentation())}');
    });

    // iOS-only event listener for notification permissions
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Notification permission status: ${state.toString()}");
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
    const Categories(),
    const FavoritesScreen(),
  ];

  void _onItemTapped(int index) async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    //---print('Tapped index: $index');---//
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> _checkFirstRunAndShowCase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = (prefs.getBool('isFirstRun') ?? true);

    if (isFirstRun) {
      Future.delayed(const Duration(seconds: 1), () =>
          ShowCaseWidget.of(context).startShowCase([_menuButtonKey]));
      prefs.setBool('isFirstRun', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CSI Kannada Hymns Book',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        leading: Builder(
          builder: (context) {
            return Showcase(
              key: _menuButtonKey,
              title: 'Sidebar',
              description: 'Tap here to open the menu for categories and settings.',
              targetShapeBorder: const CircleBorder(),
              overlayColor: Colors.black.withOpacity(0.7),
              titleTextStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
              child: IconButton(
                icon: Icon(Icons.menu, color: colorScheme.onSurface),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            );
          },
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      drawer: Sidebar(animationController: _animationController),
      body: GestureControl(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) async {
            setState(() => _selectedIndex = index);
            bool? hasVibrator = await Vibration.hasVibrator();
            if (hasVibrator) {
              Vibration.vibrate(duration: 30);
            }
          },
          children: _screens,
        ),
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        animationDuration: const Duration(milliseconds: 500),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.music_note),
            selectedIcon: Icon(Icons.music_note, color: colorScheme.onSecondaryContainer),
            label: 'Hymns',
          ),
          NavigationDestination(
            icon: const Icon(Icons.album),
            selectedIcon: Icon(Icons.album, color: colorScheme.onSecondaryContainer),
            label: 'Keerthane',
          ),
          NavigationDestination(
            icon: const Icon(Icons.category),
            selectedIcon: Icon(Icons.category, color: colorScheme.onSecondaryContainer),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite),
            selectedIcon: Icon(Icons.favorite, color: colorScheme.onSecondaryContainer),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
