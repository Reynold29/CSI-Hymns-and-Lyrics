import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:hymns_latest/keerthanes_def.dart';
import 'package:hymns_latest/keerthane_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeerthaneScreen extends StatefulWidget {
  const KeerthaneScreen({super.key});

  @override
  _KeerthaneScreenState createState() => _KeerthaneScreenState();
}

class _KeerthaneScreenState extends State<KeerthaneScreen> {
  List<Keerthane> keerthane = [];
  List<Keerthane> filteredKeerthane = [];
  String? _selectedOrder = 'number';
  String? _searchQuery;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadKeerthane().then((data) => setState(() {
      keerthane = data;
      keerthane.sort((a, b) => a.number.compareTo(b.number));
      filteredKeerthane = keerthane;
      _scrollController.addListener(_scrollListener);
    }));
    checkAndUpdateLyricsOnOpen();
  }

  Future<void> checkAndUpdateLyricsOnOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateTimestamp = prefs.getInt('lastLyricsUpdate') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updateInterval = const Duration(days: 3).inMilliseconds;

    if (now - lastUpdateTimestamp >= updateInterval) {
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/keerthane_data.json'));

        if (response.statusCode == 200) {
          final List<Keerthane> updatedKeerthane = await loadKeerthaneFromNetwork(response.body);

          setState(() {
            keerthane = updatedKeerthane;
            _sortKeerthane();
          });

          await prefs.setInt('lastLyricsUpdate', now);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lyrics updated successfully!'),
          ));
        } else {
          throw Exception('Failed to fetch data from GitHub');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update lyrics. Please try again later.'),
        ));
      }
    }
  }

  Future<void> checkAndUpdateLyrics() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Refresh Lyrics?'),
          content: const Text('Do you want to check for updated lyrics?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('YES'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Updating Lyrics...'),
              content: SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Lottie.asset('lib/assets/icons/tick-animation.json'),
                ),
              ),
            );
          },
        );
      },
    );

    fetchAndUpdateLyrics().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lyrics Updated!'),
            content: SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset('lib/assets/icons/tick-animation.json'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Failed'),
            content: const Text('Failed to update lyrics. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> fetchAndUpdateLyrics() async {
    try {
      final keerthaneResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/keerthane_data.json'));

      if (keerthaneResponse.statusCode == 200) {
        final updatedKeerthanas = await loadKeerthaneFromNetwork(keerthaneResponse.body);

        // Store updated data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('keerthaneData', jsonEncode(updatedKeerthanas));

        setState(() {
          keerthane = updatedKeerthanas;
          _sortKeerthane();
        });
      } else {
        throw Exception('Failed to fetch data from GitHub');
      }
    } catch (e) {
      print('Error updating lyrics: $e');
      rethrow;
    }
  }

  void _sortKeerthane() {
    setState(() {
      _searchQuery = null;
      if (_selectedOrder == 'number') {
        keerthane.sort((a, b) => a.number.compareTo(b.number));
      } else if (_selectedOrder == 'title') {
        keerthane.sort((a, b) => a.title.compareTo(b.title));
      }
      filteredKeerthane = List.from(keerthane);
    });
  }

  void _showFilterMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem<String>(value: "number", child: Text("Order by Keerthane Number")),
        const PopupMenuItem<String>(value: "title", child: Text("Order in Alphabetical Order")),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedOrder = value;
          _sortKeerthane();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  bool _showScrollToTopButton = false;

  void _scrollListener() {
    setState(() {
      _showScrollToTopButton = _scrollController.offset >= 400;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: custom.SearchBar(
                    hintText: 'Search Keerthane',
                    hintStyle: const TextStyle(color: Colors.black),
                    onChanged: (searchQuery) {
                      setState(() {
                        _searchQuery = searchQuery;
                        if (searchQuery.isEmpty) {
                          filteredKeerthane = List.from(keerthane);
                        } else {
                          filteredKeerthane = keerthane.where((keerthane) =>
                            keerthane.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            keerthane.number.toString().contains(searchQuery.toLowerCase())
                          ).toList();
                        }
                      });
                    },
                    focusNode: _searchFocusNode,
                    onQueryCleared: () {
                      setState(() {
                        _searchQuery = null;
                        filteredKeerthane = List.from(keerthane);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _searchFocusNode.unfocus();
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () {
                    _showFilterMenu(context);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text('Filter',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: checkAndUpdateLyrics,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text(
                        'Refresh Lyrics',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 120,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _searchQuery != null ? filteredKeerthane.length : keerthane.length,
                    itemBuilder: (context, index) {
                      final keerthaneItem = _searchQuery != null ? filteredKeerthane[index] : keerthane[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 50,
                              height: 40,
                              child: Semantics(
                                label: 'Keerthane icon',
                                child: Image.asset(
                                  'lib/assets/icons/keerthane.png',
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Keerthane ${keerthaneItem.number}: ${keerthaneItem.title}',
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                          onTap: () => navigateToKeerthaneDetail(context, keerthaneItem),
                        ),
                      );
                    },
                  ),
                  if (_showScrollToTopButton)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _scrollToTop,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        elevation: 6.0,
                        child: const Icon(Icons.arrow_upward),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToKeerthaneDetail(BuildContext context, Keerthane keerthane) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeerthaneDetailScreen(keerthane: keerthane)),
    );
  }
}
