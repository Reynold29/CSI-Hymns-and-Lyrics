import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  _ChangelogScreenState createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  @override
void initState() {
  super.initState();
  _fetchReleases();
}

List<dynamic> _releases = [];

Future<void> _fetchReleases() async {
  final url = Uri.parse('https://api.github.com/repos/Reynold29/CSI-Hymns-and-Lyrics/releases');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final releasesData = jsonDecode(response.body) as List<dynamic>; 
    setState(() {
      _releases = releasesData;
    });
  } else {
    // Handle error messages
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Changelog')),
    body: _releases.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _releases.length,
            itemBuilder: (context, index) {
              final release = _releases[index];
              return ListTile(
                title: Text(release['name']  ?? 'Release $index'), 
                subtitle: MarkdownBody(
                  data: release['body'] ?? '',
                ),  
              );
            },
          ),
  );
}
}
