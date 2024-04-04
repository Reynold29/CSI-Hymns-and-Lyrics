import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymns_latest/screens/app_theme_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  // Load saved theme preference
  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; 
    });
  }

  // Save theme preference
  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: null,
        title: const Text('Settings', style: TextStyle(fontSize: 35.0),),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Themes', style: TextStyle(fontSize: 20.0),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AppThemeScreen(initialDarkModeState: _isDarkMode),
                )
              );
            },
          ),
          // ... Other settings options
        ],
      ),
    );
  }
}