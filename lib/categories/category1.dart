import 'package:flutter/material.dart';
import 'package:hymns_latest/hymns_def.dart';
import 'package:hymns_latest/keerthanes_def.dart';
import 'package:hymns_latest/hymn_detail_screen.dart'; 
import 'package:hymns_latest/keerthane_detail_screen.dart';

class Category1Screen extends StatefulWidget {
  const Category1Screen({super.key});

  @override
  _Category1ScreenState createState() => _Category1ScreenState();
}

class _Category1ScreenState extends State<Category1Screen> {
  late Future<List<Hymn>> _hymnsFuture;
  late Future<List<Keerthane>> _keerthaneFuture;
  
  @override
  void initState() {
    super.initState();
    _hymnsFuture = loadHymns();
    _keerthaneFuture = loadKeerthane();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( 
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Jesus' Birth"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hymns'), 
              Tab(text: 'Keerthane'), 
            ],
          ),
        ),
          body: TabBarView(
            children: [
              FutureBuilder<List<Hymn>>(
                future: _hymnsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Hymn> hymns = snapshot.data!;
                    hymns.sort((a, b) => a.number.compareTo(b.number));
                    final filteredHymns = hymns.where((hymn) => hymn.number >= 76 && hymn.number <= 84).toList();
                    return ListView.builder(
                      itemCount: filteredHymns.length,
                      itemBuilder: (context, index) {
                        final hymn = filteredHymns[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 45,
                            height: 40,
                            child: Image.asset('lib/assets/icons/hymn.png')
                          ),
                          title: Text("Hymn ${hymn.number} - ${hymn.title}"
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HymnDetailScreen(hymn: hymn),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),

              FutureBuilder<List<Keerthane>>(
                future: _keerthaneFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Keerthane> keerthaneList = snapshot.data!;
                    keerthaneList.sort((a, b) => a.number.compareTo(b.number));
                    final filteredKeerthane = keerthaneList.where((keerthane) => keerthane.number >= 43 && keerthane.number <= 57).toList();
                    return ListView.builder(
                      itemCount: filteredKeerthane.length,
                      itemBuilder: (context, index) {
                        final keerthane = filteredKeerthane[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 45,
                            height: 40,
                            child: Image.asset('lib/assets/icons/keerthane.png')
                          ),
                          title: Text("Keerthane ${keerthane.number} - ${keerthane.title}"
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KeerthaneDetailScreen(keerthane: keerthane),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
  }
}
