import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hymns_latest/hymns_def.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:showcaseview/showcaseview.dart';
import 'package:hymns_latest/hymn_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  final GlobalKey _searchKey = GlobalKey();
  List<Hymn> hymns = [];
  List<Hymn> filteredHymns = [];
  Map<String, List<Hymn>> groupedHymns = {};
  String? _selectedOrder = 'number';
  String? _searchQuery;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadHymns().then((data) => setState(() {
          hymns = data;
          _sortHymns();
          _scrollController.addListener(_scrollListener);
        }));

    checkAndUpdateLyricsOnOpen();
  }

  Future<void> checkAndUpdateLyricsOnOpen() async { // Auto Lyrics Update Check
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateTimestamp = prefs.getInt('lastLyricsUpdate') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updateInterval = const Duration(days: 3).inMilliseconds;

    if (now - lastUpdateTimestamp >= updateInterval) {
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/hymns_data.json'));

        if (response.statusCode == 200) {
          final List<Hymn> updatedHymns = await loadHymnsFromNetwork(response.body);

          setState(() {
            hymns = updatedHymns;
            _sortHymns();
          });

          await prefs.setInt('lastLyricsUpdate', now);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lyrics updated successfully!'),
          ));
        } else {
          throw Exception('Failed to fetch data from cloud');
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
          content: const Text.rich(
            TextSpan(
              text: 'Do you want to check for updated lyrics?\n\n',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Pressing "YES" pulls the updated and corrected lyrics!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
      final hymnsResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/Reynold29/csi-hymns-vault/main/hymns_data.json'));
      
      if (hymnsResponse.statusCode == 200) {
        final updatedHymns = await loadHymnsFromNetwork(hymnsResponse.body);

        // Store updated data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('hymnsData', jsonEncode(updatedHymns));

        setState(() {
          hymns = updatedHymns;
          _sortHymns();
        });
      } else {
        throw Exception('Failed to fetch data from GitHub');
      }
    } catch (e) {
      print('Error updating lyrics: $e');
      rethrow;
    }
  }

  void _sortHymns() {
    setState(() {
      if (_selectedOrder == 'number') {
        hymns.sort((a, b) => a.number.compareTo(b.number));
        filteredHymns = hymns;
      } else if (_selectedOrder == 'title') {
        hymns.sort((a, b) => a.title.compareTo(b.title));
        filteredHymns = hymns;
      } else if (_selectedOrder == 'time_signature') {
        hymns.sort((a, b) => a.signature.compareTo(b.signature));
        _groupHymnsBySignature();
      }
      _filterHymns();
    });
  }

  void _filterHymns() {
    setState(() {
      if (_searchQuery == null || _searchQuery!.isEmpty) {
        filteredHymns = List.from(hymns);
        if (_selectedOrder == 'time_signature') {
          _groupHymnsBySignature();
        }
      } else {
        final query = _searchQuery!.toLowerCase().trim(); 
        if (_selectedOrder == 'time_signature') {
          groupedHymns = Map.fromEntries(
            groupedHymns.entries.where((entry) {
              // ignore: unused_local_variable
              final signature = entry.key.toLowerCase();
              final hymnsInSignature = entry.value.where((hymn) => 
                hymn.title.toLowerCase().contains(query) ||
                hymn.number.toString().contains(query) ||
                hymn.signature.toLowerCase().contains(query)
              ).toList();
              return hymnsInSignature.isNotEmpty;
            })
          );
          filteredHymns = groupedHymns.values.expand((x) => x).toList();
        } else {
          filteredHymns = hymns.where((hymn) {
            final hymnSignature = hymn.signature.toLowerCase();
            return hymn.title.toLowerCase().contains(query) ||
                   hymn.number.toString().contains(query) ||
                   hymnSignature == query; 
          }).toList();
        }
      }
    });
  }

  void _groupHymnsBySignature() {
    groupedHymns.clear();
    for (var hymn in hymns) {
      if (!groupedHymns.containsKey(hymn.signature)) {
        groupedHymns[hymn.signature] = [];
      }
      groupedHymns[hymn.signature]!.add(hymn);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem<String>(value: "number", child: Text("Order by Hymn Number")),
        const PopupMenuItem<String>(value: "title", child: Text("Order in Alphabetical Order")),
        const PopupMenuItem<String>(value: "time_signature", child: Text("Order by Tune Meter")),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedOrder = value;
          _sortHymns();
        });
      }
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: custom.SearchBar(
          hintText: 'Search Hymns (Number, Title, Meter)',
          onChanged: (searchQuery) {
            setState(() {
              _searchQuery = searchQuery;
              _filterHymns();
            });
          },
          focusNode: _searchFocusNode,
          onQueryCleared: () {
            setState(() {
              _searchQuery = null;
              _filterHymns();
              if (_selectedOrder == 'time_signature') _groupHymnsBySignature();
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchFocusNode.unfocus();
              });
            });
          },
          backgroundColor: colorScheme.surfaceContainerHighest,
          searchIconColor: colorScheme.onSurfaceVariant,
          clearIconColor: colorScheme.onSurfaceVariant,
          textStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Hymns',
            color: colorScheme.onSurface,
            onPressed: () => _showFilterMenu(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Lyrics',
            color: colorScheme.onSurface,
            onPressed: checkAndUpdateLyrics,
          ),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: _selectedOrder == 'time_signature'
                        ? groupedHymns.keys.length
                        : filteredHymns.length,
                    itemBuilder: (context, index) {
                      if (_selectedOrder == 'time_signature') {
                        String signature = groupedHymns.keys.elementAt(index);
                        List<Hymn> hymnsInSignature = groupedHymns[signature]!;
                        if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                          hymnsInSignature = hymnsInSignature.where((hymn) =>
                              hymn.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                              hymn.number.toString().contains(_searchQuery!.toLowerCase()) ||
                              hymn.signature.toLowerCase().contains(_searchQuery!.toLowerCase())).toList();
                        }
                        if (hymnsInSignature.isEmpty) return const SizedBox.shrink();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: colorScheme.outlineVariant, width: 1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    signature,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ...hymnsInSignature.map((hymn) => _buildHymnListTile(hymn)),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final hymn = filteredHymns[index];
                        return _buildHymnListTile(hymn);
                      }
                    },
                  ),
                  if (_showScrollToTopButton)
                    Positioned(
                      bottom: 16,
                      right: 0,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _scrollToTop,
                        backgroundColor: colorScheme.tertiaryContainer,
                        foregroundColor: colorScheme.onTertiaryContainer,
                        elevation: 3.0,
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

  Widget _buildHymnListTile(Hymn hymn) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0, // M3 style: flat with outline
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0), // Adjust margin as needed
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0), // Adjust padding for image
          child: SizedBox(
            width: 40, // Original width
            height: 40, // Original height
            child: Image.asset(
              'lib/assets/icons/hymn.png', // Restore original image
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important for Column in ListTile
          children: [
            Text(
              'Hymn ${hymn.number}: ${hymn.title}',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
            ),
            if (hymn.signature.isNotEmpty) ...[
              const SizedBox(height: 4.0), // Gap between title and subtitle
              Text(
                hymn.signature, 
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)
              ),
            ]
          ],
        ),
        // subtitle property is removed as it's now part of the title Column
        trailing: Icon(Icons.chevron_right, color: colorScheme.secondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HymnDetailScreen(hymn: hymn),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }

  void navigateToHymnDetail(BuildContext context, Hymn hymn) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
    );
  }
}