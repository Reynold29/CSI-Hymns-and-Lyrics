import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'hymns_def.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String selectedLanguage = 'Kannada';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hymn.title),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row( // Row for top position
              children: [
                Spacer(), // Pushes chips to the right
                ChoiceChip(
                  label: const Text('English'),
                  selected: selectedLanguage == 'English',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        selectedLanguage = 'English';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8), 
                ChoiceChip(
                  label: const Text('Kannada'),
                  selected: selectedLanguage == 'Kannada',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        selectedLanguage = 'Kannada';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16), // Space below the chips 
            Text(
              'Hymn ${widget.hymn.number}', // Number in the left corner
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.hymn.signature,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Center( 
              child: Text(
                selectedLanguage == 'English' 
                  ? widget.hymn.lyrics 
                  : (widget.hymn.kannadaLyrics ?? 'Kannada Lyrics unavailable'), 
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
