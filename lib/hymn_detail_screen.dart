import 'hymns_def.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String selectedLanguage = 'Kannada';
  bool _isFavorite = false;
  double _fontSize = 18.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  final Duration _skipDuration = const Duration(seconds: 5);

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
  void initState() {
    super.initState();
    _checkIsFavorite();
    _initAudioPlayer(); 
  }

  Future<void> _checkIsFavorite() async {
    final favoriteIds = await _retrieveFavorites();
    setState(() {
      _isFavorite = favoriteIds.contains(widget.hymn.number);
    });
  }

  Future<void> _toggleFavorite() async {
  if (_isFavorite) {
    await _removeFromFavorites(widget.hymn);
  } else {
    await _saveToFavorites(widget.hymn);
  }

  bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(duration: 100);
    }

    await _checkIsFavorite();
  }

  Future<void> _initAudioPlayer() async {
    String hymnNumber = widget.hymn.number.toString();
    String audioUrl = 'https://raw.githubusercontent.com/reynold29/midi-files/main/Hymn_$hymnNumber.ogg';

    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudioPlayback() {
    setState(() {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Find something wrong in the lyrics? ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Help me fix it by sending an E-Mail! \n\nSend E-Mail?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  query: 'subject=Hymn%20Lyrics%20Issue%20-%20Hymn%20${widget.hymn.number}&body=Requesting%20lyrics%20check!',
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Unable to open email app. Do you have Gmail installed?')));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToFavorites(Hymn hymn) async {
  final prefs = await SharedPreferences.getInstance();
  final storedIds = prefs.getStringList('favoriteHymnIds') ?? [];

    if (!storedIds.contains(hymn.number.toString())) { 
      storedIds.add(hymn.number.toString());
      await prefs.setStringList('favoriteHymnIds', storedIds);
    }
  }

  Future<void> _removeFromFavorites(Hymn hymn) async {
    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList('favoriteHymnIds') ?? [];

    if (storedIds.contains(hymn.number.toString())) {
      storedIds.remove(hymn.number.toString());
      await prefs.setStringList('favoriteHymnIds', storedIds);
    }
  }

  Future<List<int>> _retrieveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getStringList('favoriteHymnIds');
    final favoriteIds = storedData?.map((idStr) => int.parse(idStr)).toList() ?? [];
    return favoriteIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hymn.title),
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
                const Text('Font', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text('ಕನ್ನಡ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                  'Hymn ${widget.hymn.number}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 15),
                StatefulBuilder(
                  builder: (context, setState) {
                  return FavoriteButton(
                    key: ValueKey(_isFavorite),
                    isFavorite: _isFavorite,
                    valueChanged: (isFavorite) {
                      _toggleFavorite();
                      setState(() {});
                    },
                    iconSize: 38,
                  );
                }),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_5_rounded),
                      onPressed: () {
                        Duration newPosition = _audioPlayer.position - _skipDuration;
                        if (newPosition < Duration.zero) {
                          newPosition = Duration.zero; 
                        }
                        _audioPlayer.seek(newPosition); 
                      },
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _toggleAudioPlayback,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_5_rounded),
                      onPressed: () async {
                        final currentPosition = _audioPlayer.position;
                        final newPosition = currentPosition + _skipDuration;
                        if (newPosition > (await _audioPlayer.duration)!) {
                          _audioPlayer.stop();
                        } else {
                          _audioPlayer.seek(newPosition);
                        }
                      },
                    ),
                  ],
                ),
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
              widget.hymn.signature,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                child: Text(
                  selectedLanguage == 'English'
                      ? widget.hymn.lyrics
                      : (widget.hymn.kannadaLyrics ?? 'Kannada Lyrics unavailable'),
                  style: TextStyle(fontSize: _fontSize),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
