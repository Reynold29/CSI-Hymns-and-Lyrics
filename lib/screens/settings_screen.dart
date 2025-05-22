import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hymns_latest/theme_state.dart';
import 'package:hymns_latest/widgets/update_check.dart';
import 'package:hymns_latest/screens/changelog_screen.dart';
import 'package:hymns_latest/screens/about_app.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);
    // Determine the current visual theme status for the toggle
    bool currentVisualIsDark;
    if (themeState.themeMode == ThemeMode.system) {
      currentVisualIsDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    } else {
      currentVisualIsDark = themeState.themeMode == ThemeMode.dark;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        children: <Widget>[
          _buildSectionHeader(context, 'Appearance', FontAwesomeIcons.palette),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: currentVisualIsDark, // Use the determined visual state for the toggle value
            onChanged: (bool value) {
              // When toggled, explicitly set to Light or Dark
              themeState.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: Icon(currentVisualIsDark ? FontAwesomeIcons.solidMoon : FontAwesomeIcons.moon),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          if (currentVisualIsDark) // AMOLED option visibility based on current visual dark state
            SwitchListTile(
              title: const Text('AMOLED Black Mode'),
              subtitle: const Text('Uses true black for dark theme backgrounds'),
              value: themeState.blackThemeEnabled,
              onChanged: (bool value) {
                themeState.setBlackThemeEnabled(value);
              },
              secondary: const Icon(FontAwesomeIcons.paintRoller),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ListTile(
            title: const Text('Theme Color'),
            subtitle: const Text('Tap to change the app\'s primary color'),
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: themeState.seedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
            ),
            onTap: () => _showColorPickerDialog(context, themeState),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'App Information', FontAwesomeIcons.circleInfo),
          ListTile(
            leading: const Icon(FontAwesomeIcons.cloudArrowDown),
            title: const Text('Check for Updates'),
            onTap: () {
              final updateManager = UpdateManager();
              updateManager.checkForUpdates(context);
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.scroll),
            title: const Text('What\'s New? (Changelog)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangelogScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.book),
            title: const Text('About App'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutApp()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context, ThemeState themeState) async {
    final colorBeforeDialog = themeState.seedColor;
    Color newColor = themeState.seedColor;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose Theme Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: newColor,
              onColorChanged: (Color color) {
                newColor = color;
              },
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: false,
                ColorPickerType.custom: false,
                ColorPickerType.wheel: true,
              },
              enableShadesSelection: true,
              width: 40,
              height: 40,
              borderRadius: 20,
              spacing: 5,
              runSpacing: 5,
              wheelDiameter: 165,
              showMaterialName: true,
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                longPressMenu: true,
              ),
              actionButtons: const ColorPickerActionButtons(
                okButton: true,
                closeButton: true,
                dialogActionButtons: false, // Using AlertDialog actions
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Optionally revert color if needed, though current setup updates live
                // themeState.setSeedColor(colorBeforeDialog);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                themeState.setSeedColor(newColor);
              },
            ),
          ],
        );
      },
    );
  }
}