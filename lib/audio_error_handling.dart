import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AudioErrorDialog extends StatelessWidget {
  final int itemNumber;
  final String itemType;

  const AudioErrorDialog({super.key, required this.itemNumber, required this.itemType});

  void _showThankYouBox(BuildContext context) {
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              'Thank you for your contribution!',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Audio Unavailable',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Audio file is not available for this $itemType.\n\nWould you like to provide the audio file, if available?',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Yes'),
          onPressed: () async {
            Navigator.pop(context);

            _showThankYouBox(context);

            await Future.delayed(const Duration(seconds: 2));

            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'reyziecrafts@gmail.com',
              query: 'subject=Missing%20Audio%20-%20$itemType%20$itemNumber&body=Audio%20file%20is%20missing%20for%20$itemType%20$itemNumber.%20I%20might%20be%20able%20to%20provide%20the%20audio%20file.',
            );
            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Unable to open email app. Do you have Gmail installed?')));
            }
          },
        ),
      ],
    );
  }
}