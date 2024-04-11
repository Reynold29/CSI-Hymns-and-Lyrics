import 'package:flutter/material.dart';
import 'package:hymns_latest/theme_state.dart';
import 'package:provider/provider.dart';
import 'package:hymns_latest/widgets/update_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymns_latest/screens/app_theme_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isBlackMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ??
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      _isBlackMode = prefs.getBool('isBlackMode') ?? false;
    });
  }

  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setBool('isBlackMode', _isBlackMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0, fontFamily: 'plusJakartaSans'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                'Themes',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppThemeScreen(initialDarkModeState: _isDarkMode)),
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
                  Provider.of<ThemeState>(context, listen: false).setThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
                  _saveThemePreference();
                },
              ),
            ),
            ListTile(
              title: const Text('Black Theme'),
              subtitle: const Text("This feature is currently not available!",
              style: TextStyle(fontStyle: FontStyle.italic),
              ),
              trailing: Switch(
                value: _isBlackMode,
                onChanged: (newValue) {
                  setState(() {
                    _isBlackMode = newValue;
                  });
                  Provider.of<ThemeState>(context, listen: false).setBlackThemeEnabled(newValue);
                  _saveThemePreference();
                },
              ),
            ),
            ListTile(
            title: const Text('Check for Updates'),
            onTap: () {
              final updateManager = UpdateManager();
              updateManager.checkForUpdates(context);
            },
          ),
        ],
      ),
    ),
  );
}
}