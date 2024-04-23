import 'package:flutter/material.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';
import 'package:hymns_latest/hymns_def.dart';
import 'package:hymns_latest/keerthane_detail_screen.dart';
import 'package:hymns_latest/keerthanes_def.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  List<Hymn> _favoriteHymns = [];
  List<Keerthane> _favoriteKeerthane = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favoriteIdsMap = await _retrieveFavorites();
    final hymns =
        await _fetchHymnsByIds(favoriteIdsMap['favoriteHymnIds'] ?? []);
    final keerthane =
        await _fetchKeerthaneByIds(favoriteIdsMap['favoriteKeerthaneIds'] ?? []);
    setState(() {
      _favoriteHymns = hymns;
      _favoriteKeerthane = keerthane;
    });
  }

  Future<Map<String, List<int>>> _retrieveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'favoriteHymnIds': prefs.getStringList('favoriteHymnIds')?.map((idStr) => int.parse(idStr)).toList() ?? [],
      'favoriteKeerthaneIds': prefs.getStringList('favoriteKeerthaneIds')?.map((idStr) => int.parse(idStr)).toList() ?? [],
    };
  }

  Future<List<Hymn>> _fetchHymnsByIds(List<int> ids) async {
    final List<Hymn> allHymns = await loadHymns();
    return allHymns.where((hymn) => ids.contains(hymn.number)).toList();
  }

  Future<List<Keerthane>> _fetchKeerthaneByIds(List<int> ids) async {
    final List<Keerthane> allKeerthane = await loadKeerthane();
    return allKeerthane.where((keerthane) => ids.contains(keerthane.number)).toList();
  }

  Future<void> _removeFromFavorites(dynamic item, {required String hymnType}) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = hymnType == 'hymn' ? 'favoriteHymnIds' : 'favoriteKeerthaneIds';
    final storedIds = prefs.getStringList(key) ?? [];

    storedIds.remove(item.number.toString());
    await prefs.setStringList(key, storedIds);

    setState(() {
      if (hymnType == 'hymn') {
        _favoriteHymns.remove(item);
      } else {
        _favoriteKeerthane.remove(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Hymns'),
              Tab(text: 'Keerthanes'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Hymn list
            _favoriteHymns.isEmpty
                ? const Center(child: Text('No Favorite Hymns'))
                : ListView.builder(
                    itemCount: _favoriteHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = _favoriteHymns[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HymnDetailScreen(hymn: hymn),
                          ),
                        ),
                        child: ListTile(
                          title: Text(hymn.title),
                          subtitle: Text('Hymn Number: ${hymn.number}'),
                          trailing: PopupMenuButton<int>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Remove from Favorites'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 1) {
                                _removeFromFavorites(hymn, hymnType: 'hymn');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
            // Keerthane list
            _favoriteKeerthane.isEmpty
                ? const Center(child: Text('No Favorite Keerthane'))
                : ListView.builder(
                    itemCount: _favoriteKeerthane.length,
                    itemBuilder: (context, index) {
                      final keerthane = _favoriteKeerthane[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KeerthaneDetailScreen(keerthane: keerthane),
                          ),
                        ),
                        child: ListTile(
                          title: Text(keerthane.title),
                          subtitle: Text('Keerthane Number: ${keerthane.number}'),
                          trailing: PopupMenuButton<int>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Remove from Favorites'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 1) {
                                _removeFromFavorites(keerthane, hymnType: 'keerthane');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
