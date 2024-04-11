import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'keerthanes_def.dart';

class KeerthaneDetailScreen extends StatefulWidget {
  final Keerthane keerthane;

  const KeerthaneDetailScreen({super.key, required this.keerthane});

  @override
  _KeerthaneDetailScreenState createState() => _KeerthaneDetailScreenState();
}

class _KeerthaneDetailScreenState extends State<KeerthaneDetailScreen> {
  String selectedLanguage = 'Kannada';
  double _fontSize = 18.0;

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 2).clamp(16.0, 40.0); 
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(16.0, 40.0); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keerthane.title),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              children: [
                InkWell( 
                  onTap: _decreaseFontSize, 
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, 
                      color: Color.fromARGB(138, 247, 229, 255),
                    ),
                    child: const Icon(Icons.remove), 
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Font Size', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8), 
                InkWell(
                  onTap: _increaseFontSize, 
                  child: Container( 
                    padding: const EdgeInsets.all(5.0), 
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, 
                      color: Color.fromARGB(138, 247, 229, 255),
                    ),
                    child: const Icon(Icons.add), 
                  ),
                ),
                const Spacer(),
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
              'Keerthane ${widget.keerthane.number}', // Number in the left corner
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.keerthane.signature,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Center( 
              child: Text(
                selectedLanguage == 'English' 
                  ? widget.keerthane.lyrics 
                  : (widget.keerthane.kannadaLyrics ?? 'Kannada Lyrics unavailable'), 
                style: TextStyle(fontSize: _fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
