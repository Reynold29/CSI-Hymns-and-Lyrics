import 'package:flutter/material.dart';
import 'package:hymns_latest/hymns_def.dart';
import 'package:hymns_latest/keerthanes_def.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';
import 'package:hymns_latest/keerthane_detail_screen.dart';

class DynamicCategoryScreen extends StatelessWidget {
  final String category;
  final List<int>? hymnNumbers;
  final List<int>? keerthaneNumbers;

  const DynamicCategoryScreen({
    super.key,
    required this.category,
    this.hymnNumbers,
    this.keerthaneNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final showHymns = hymnNumbers != null && hymnNumbers!.isNotEmpty;
    final showKeerthanes = keerthaneNumbers != null && keerthaneNumbers!.isNotEmpty;

    final tabs = <Tab>[];
    final views = <Widget>[];

    if (showHymns) {
      tabs.add(const Tab(text: 'Hymns'));
      views.add(_buildHymnsTab());
    }

    if (showKeerthanes) {
      tabs.add(const Tab(text: 'Keerthanes'));
      views.add(_buildKeerthanesTab());
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$category ${showHymns && showKeerthanes ? "Hymns & Keerthanes" : showHymns ? "Hymns" : "Keerthanes"}'),
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(children: views),
      ),
    );
  }

  Widget _buildHymnsTab() {
    return FutureBuilder<List<Hymn>>(
      future: loadHymns(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final hymns = snapshot.data!;
          final filtered = hymns.where((h) => hymnNumbers!.contains(h.number)).toList();
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final hymn = filtered[index];
              return ListTile(
                leading: SizedBox(
                  width: 45,
                  height: 40,
                  child: Image.asset('lib/assets/icons/hymn.png'),
                ),
                title: Text("Hymn ${hymn.number} - ${hymn.title}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HymnDetailScreen(hymn: hymn)),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildKeerthanesTab() {
    return FutureBuilder<List<Keerthane>>(
      future: loadKeerthane(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final keers = snapshot.data!;
          final filtered = keers.where((k) => keerthaneNumbers!.contains(k.number)).toList();
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final keerthane = filtered[index];
              return ListTile(
                leading: SizedBox(
                  width: 45,
                  height: 40,
                  child: Image.asset('lib/assets/icons/keerthane.png'),
                ),
                title: Text("Keerthane ${keerthane.number} - ${keerthane.title}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KeerthaneDetailScreen(keerthane: keerthane)),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
