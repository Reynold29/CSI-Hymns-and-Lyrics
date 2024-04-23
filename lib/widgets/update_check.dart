import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateManager {
  Future<void> checkForUpdates(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Checking for Updates...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Please wait...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    try {
      final latestVersion = await fetchLatestVersionFromServer(); 
      const currentVersion = '1.0.0'; 

      if (latestVersion != currentVersion && await _shouldCheckForUpdate()) {
        Navigator.pop(context);
        await showDialog( 
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('New Update Available!'),
            content: Text('Version $latestVersion is available. Would you like to update now?'), 
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () {
                  print('Initiate Play Store Update'); 
                  Navigator.pop(context); 
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pop(context);
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Updates Available!'),
            content: const Text("You're already on the latest version!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error checking for updates: $e'); 
    } 
  }

  Future<String> fetchLatestVersionFromServer() async {
    return '1.0.0'; 
  }

  Future<bool> _shouldCheckForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckTime = prefs.getInt('last_update_check');
    final now = DateTime.now();

    if (lastCheckTime == null || now.difference(DateTime.fromMillisecondsSinceEpoch(lastCheckTime)).inDays >= 5) {
      await prefs.setInt('last_update_check', now.millisecondsSinceEpoch);
      return true;
    } else {
      return false;
    }
  }
}
