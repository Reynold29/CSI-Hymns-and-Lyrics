import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateManager {
  final String _storeUrl = "https://play.google.com/store/apps/details?id=com.reyzie.hymns";  

  Future<void> checkForUpdates(BuildContext context) async {
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _launchStorePage();
      }
    }).catchError((e) {
      print('Error checking for update: $e');
    });
  }

  void _launchStorePage() async {
    if (await canLaunchUrl(Uri.parse(_storeUrl))) {
      await launchUrl(Uri.parse(_storeUrl));
    } else {
      print('Could not launch store page');
    }
  }
}
