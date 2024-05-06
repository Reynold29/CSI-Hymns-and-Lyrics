import 'about_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hymns_latest/theme_state.dart';
import 'package:hymns_latest/widgets/update_check.dart';
import 'package:hymns_latest/screens/changelog_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
            const ListTile(
              leading: FaIcon(FontAwesomeIcons.palette),
              title: Text(
                'Themes',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),
              ),
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
            const Divider(),
            const ListTile(
              leading: FaIcon(FontAwesomeIcons.cloudArrowDown),
              title: Text(
                'Updates',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),
              ),
            ),
            ListTile(
            title: const Text('Check for Updates'),
            onTap: () {
              final updateManager = UpdateManager();
              updateManager.checkForUpdates(context);
            },
          ),
          const Divider(),
          const ListTile(
            leading: FaIcon(FontAwesomeIcons.scroll),
            title: Text(
            "What's New?",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0)
            ),
          ),
          ListTile(
            title: const Text('Have a look at the Changelog!'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangelogScreen()),
              );
            },
          ),
          const Divider(),
            const ListTile(
              leading: FaIcon(FontAwesomeIcons.circleInfo),
              title: Text(
                'About App',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),
              ),
            ),
          ListTile(
            title: const Text('Learn More about the app!'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutApp()),
              );
            },
          ),
        ],
      ),
    ),
  );
 }
}