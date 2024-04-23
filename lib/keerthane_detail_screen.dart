import 'keerthanes_def.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _showFeedbackDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Something wrong with the lyrics? ',
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('\nHelp me fix it by sending an E-Mail! \n\nSend E-Mail?',
        style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ), 
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Yes'), 
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'reynold29clare@gmail.com',
                query: 'subject=Keerthane%20Lyrics%20Issue%20-%20Keerthane%20${widget.keerthane.number}&body=Requesting%20lyrics%20check!', 
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else { 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to open email app. Do you have Gmail installed?')) 
                );
              }
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
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
                const Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            const Divider(),
            Row(
              children: [
                Text(
                  'Keerthane ${widget.keerthane.number}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: 50.0, 
                    height: 50.0,
                    child: FloatingActionButton(
                      onPressed: _showFeedbackDialog,
                      tooltip: 'Report Lyrics Issue',
                      child: const Icon(Icons.bug_report),
                    ),
                  ),
                ),
              ],
            ),
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
