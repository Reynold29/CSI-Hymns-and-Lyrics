import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeScreen extends StatefulWidget {
  final bool initialDarkModeState;

  const AppThemeScreen({super.key, required this.initialDarkModeState}); 

  @override
  _AppThemeScreenState createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkModeState; 
    _loadThemePreference(); 
  }

    void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; 
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Theme'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (newValue) {
                setState(() {
                  _isDarkMode = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}