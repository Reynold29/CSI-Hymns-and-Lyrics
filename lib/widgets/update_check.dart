import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateManager {
  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Show the in-app update dialog
        await InAppUpdate.performImmediateUpdate();
      } else {
        // Already up to date
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You're on the latest version!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking for update: $e')),
      );
    }
  }
}
