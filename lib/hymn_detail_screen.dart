import 'package:flutter/material.dart';
import 'hymns_def.dart';

class HymnDetailScreen extends StatelessWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hymn.title),
      ),
      body: SingleChildScrollView( // Use for potentially long hymns
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hymn ${hymn.number}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (hymn.signature != null) // Display signature if exists
              Text(
                hymn.signature!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16),
            Center(
              child: Text(
              hymn.lyrics, 
              style: const TextStyle(fontSize: 18),
              )
            ),
          ],
        ),
      ),
    );
  }
}
