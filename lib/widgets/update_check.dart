import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:url_launcher/url_launcher.dart';

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
      final response = await http.get(
          Uri.parse('https://api.github.com/repos/Reynold29/CSI-Hymns-and-Lyrics/releases/latest'));

      if (response.statusCode == 200) {
        final releaseData = jsonDecode(response.body);
        final latestVersion = releaseData['v3-beta'];

        const currentVersion = '2.0.1';

        if (latestVersion != currentVersion) {
          Navigator.pop(context); 

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Update Available!'),
              content: Text('Version $latestVersion is available.'), 
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final downloadUrl = releaseData['html_url'];
                    await launchUrl(Uri.parse(downloadUrl));
                    Navigator.pop(context);
                  },
                  child: const Text('Download'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No updates available!'),
              content: const Text("No updates were found! You're Up-To-Date! ;)"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Network Error'),
            content: const Text('Network error detected! Try again after some time.'),
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      Navigator.pop(context);
    }
  }
}
