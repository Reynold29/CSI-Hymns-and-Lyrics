import 'package:flutter/material.dart';
import 'package:hymns_latest/theme_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymns_latest/screens/app_theme_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

@override 
  void initState() { 
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    // Check for preference, or default to system theme
    _isDarkMode = prefs.getBool('isDarkMode') ?? 
                  MediaQuery.of(context).platformBrightness == Brightness.dark; 
  });
}

  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: null,
        title: const Text('Settings', style: TextStyle(fontSize: 35.0),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Themes', style: TextStyle(fontSize: 25.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AppThemeScreen(initialDarkModeState: _isDarkMode),
                )
              );
            },
          ),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (newValue) {
                setState(() {
                  _isDarkMode = newValue;
                });
                Provider.of<ThemeState>(context, listen: false)
                    .setThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
                _saveThemePreference();
              },
            ),
          ),
        ],
      ),
    );
  }
}