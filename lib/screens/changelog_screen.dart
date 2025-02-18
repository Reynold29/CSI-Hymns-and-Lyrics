import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hymns_latest/models/changelog_model.dart';

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  _ChangelogScreenState createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  List<ChangelogEntry> _changelogData = [];
  
@override
void initState() {
  super.initState();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _loadChangelog();
  });
}

Future<void> _loadChangelog() async {
  final jsonString = await rootBundle.loadString('lib/assets/changelog.json'); 

  final jsonData = jsonDecode(jsonString) as List<dynamic>;

  setState(() {
    _changelogData = jsonData.map((entry) => ChangelogEntry.fromJson(entry)).toList();
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Changelog')),
    body: _changelogData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _changelogData.length,
            itemBuilder: (context, index) {
              final entry = _changelogData[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
                      ),
                      const SizedBox(height: 8),
                      Text('Version: ${entry.version}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                      ),
                      Text('Date: ${entry.date}',
                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                    ),
                      const SizedBox(height: 12),  
                      Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: entry.changes.map((change) => Text('- $change')).toList(),
                      ), 
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}