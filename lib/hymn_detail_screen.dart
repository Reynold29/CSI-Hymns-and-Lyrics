import 'dart:async';
import 'hymns_def.dart';
import 'audio_error_handling.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audio_session/audio_session.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String selectedLanguage = 'Kannada';
  bool _isFavorite = false;
  bool _isLooping = false;
  double _fontSize = 18.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMiniPlayerVisible = false;
  double _playbackSpeed = 1.0;

  final Duration _skipDuration = const Duration(seconds: 5);
  final _audioButtonHeroTag = const Symbol('audioButtonHeroTag');
  final _debugButtonHeroTag = const Symbol('debugButtonHeroTag');
  late StreamSubscription<PlayerState> _playerStateSubscription;

  void _increaseFontSize() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    setState(() {
      _fontSize = (_fontSize + 2).clamp(16.0, 40.0);
    });
  }

  void _decreaseFontSize() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    setState(() {
      _fontSize = (_fontSize - 2).clamp(16.0, 40.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIsFavorite();
    _init();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState.playing;
      if (playerState.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });
  });
}

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('Playback stream error occurred: $e');
      print('Stack trace: $stackTrace');
    });

    String hymnNumber = widget.hymn.number.toString();
    String audioUrl = 'https://raw.githubusercontent.com/reynold29/midi-files/main/Hymn_$hymnNumber.ogg';

    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    } catch (e) {
      print('Error loading audio source: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AudioErrorDialog(
            itemNumber: widget.hymn.number,
            itemType: 'Hymn',
          ),
        );
      }
    }
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
    if (hasVibrator) {
      Vibration.vibrate(duration: 100);
    }

    await _checkIsFavorite();
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudioPlayback() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    setState(() {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _showFeedbackDialog() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
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
                  path: 'reyziecrafts@gmail.com',
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

  void _toggleMiniPlayerVisibility() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    if (!_isMiniPlayerVisible) {
        if (_audioPlayer.audioSource == null) {
            String hymnNumber = widget.hymn.number.toString();
            String audioUrl = 'https://raw.githubusercontent.com/reynold29/midi-files/main/Hymn_$hymnNumber.ogg';

            try {
                await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
            } catch (e) {
                print('Error loading audio source: $e');
                showDialog(
                    context: context,
                    builder: (context) => AudioErrorDialog(
                        itemNumber: widget.hymn.number,
                        itemType: 'Hymn',
                    ),
                );
                return;
            }
        }
    } else {
        await _audioPlayer.pause();
    }
    setState(() {
        _isMiniPlayerVisible = !_isMiniPlayerVisible;
    });

    if (_isMiniPlayerVisible) {
        _playbackSpeed = 1.0;
        try {
            if (_audioPlayer.audioSource != null) {
                await _audioPlayer.setSpeed(_playbackSpeed);
            }
        } catch (e) {
            print("Error resetting playback speed: $e");
        }
    }
  }

  void _onAudioCompleted() {
    print("Audio playback completed!");

    if (_isLooping) {
        print("Loop mode is ON - restarting audio.");
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
    } else {
        print("Loop mode is OFF - pausing audio.");
        setState(() {
            _isPlaying = false;
        });
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
    }
  }

  void _toggleLoop() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    setState(() {
        _isLooping = !_isLooping;
    });
    print("Loop mode toggled: _isLooping = $_isLooping");
  }

  void _setPlaybackSpeed(double speed) async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
    print("setPlaybackSpeed called with speed: $speed (Simplified Navigation)");
    setState(() {
        _playbackSpeed = speed;
    });
    try {
        print("Before _audioPlayer.setSpeed(speed), audioSource: ${_audioPlayer.audioSource}");
        if (_audioPlayer.audioSource != null) {
            await _audioPlayer.setSpeed(speed);
        } else {
            print("Audio source is still null when trying to change speed (inside IF).");
        }
    } catch (e) {
        print("Error setting playback speed: $e");
    } finally {
        print("setPlaybackSpeed finally block - Navigation MINIMAL - NO Navigator.pop()");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hymn.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        },
                      ),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('English'),
                        selected: selectedLanguage == 'English',
                        onSelected: (bool selected) async {
                            bool? hasVibrator = await Vibration.hasVibrator();
                            if (hasVibrator) {
                              Vibration.vibrate(duration: 30);
                            }
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
                          child: Text(
                            'ಕನ್ನಡ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        selected: selectedLanguage == 'Kannada',
                        onSelected: (bool selected) async {
                            bool? hasVibrator = await Vibration.hasVibrator();
                            if (hasVibrator) {
                              Vibration.vibrate(duration: 30);
                            }
                          if (selected) {
                            setState(() {
                              selectedLanguage = 'Kannada';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (widget.hymn.signature.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.hymn.signature,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                  const Divider(),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: FloatingActionButton(
                                heroTag: _audioButtonHeroTag,
                                onPressed: _toggleMiniPlayerVisibility,
                                tooltip: 'Open Audio Player',
                                child: Icon(_isMiniPlayerVisible ? Icons.music_note : Icons.music_note),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0),
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: FloatingActionButton(
                                heroTag: _debugButtonHeroTag,
                                onPressed: _showFeedbackDialog,
                                tooltip: 'Report Lyrics Issue',
                                child: const Icon(Icons.bug_report),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  SizedBox(height: _isMiniPlayerVisible ? 80.0 : 0),
                ],
              ),
            ),
          ),
          if (_isMiniPlayerVisible)
            _buildMiniAudioPlayer(context),
        ],
      ),
    );
  }

  Widget _buildMiniAudioPlayer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.hymn.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _toggleMiniPlayerVisibility,
              ),
            ],
          ),
  StreamBuilder<Duration>(
    stream: _audioPlayer.positionStream,
    builder: (context, snapshot) {
        Duration? position = snapshot.data;
        Duration? duration = _audioPlayer.duration;
        double sliderValue = position?.inMilliseconds.toDouble() ?? 0.0;
        double sliderMax = duration?.inMilliseconds.toDouble() ?? 100.0;

        sliderValue = sliderValue.clamp(0.0, sliderMax);

        return Column(
            children: [
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Colors.grey[700],
                        thumbColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Slider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Colors.grey[700],
                        thumbColor: Theme.of(context).colorScheme.primary,
                        value: sliderValue,
                        max: sliderMax,
                        min: 0.0,
                        onChanged: (value) {
                            final newPosition = Duration(milliseconds: value.toInt());
                            _audioPlayer.seek(newPosition);
                        },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position ?? Duration.zero), style: const TextStyle(color: Colors.white70)),
                        Text(_formatDuration(duration ?? Duration.zero), style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_5_rounded, color: Colors.white, size: 26),
                onPressed: () {
                  Duration newPosition = _audioPlayer.position - _skipDuration;
                  if (newPosition < Duration.zero) {
                    newPosition = Duration.zero;
                  }
                  _audioPlayer.seek(newPosition);
                },
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 38),
                onPressed: _toggleAudioPlayback,
              ),
              IconButton(
                icon: const Icon(Icons.forward_5_rounded, color: Colors.white, size: 26),
                onPressed: () async {
                  final currentPosition = _audioPlayer.position;
                  final newPosition = currentPosition + _skipDuration;
                  if (newPosition > (_audioPlayer.duration)!) {
                    _audioPlayer.stop();
                  } else {
                    _audioPlayer.seek(newPosition);
                  }
                },
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setStateSB) {
                    bool _isButtonPushed = false;

                    return IconButton(
                        icon: AnimatedScale(
                            // ignore: dead_code
                            scale: _isButtonPushed ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: FaIcon(
                                FontAwesomeIcons.repeat,
                                color: _isLooping
                                    ? const Color.fromARGB(255, 133, 3, 255)
                                    : Colors.white,
                                size: 20,
                            ),
                        ),
                        tooltip: _isLooping ? 'Loop On' : 'Loop Off',
                        onPressed: () {
                            _toggleLoop();
                            setStateSB(() {
                                _isButtonPushed = true;
                            });
                            Future.delayed(const Duration(milliseconds: 150), () {
                                setStateSB(() {
                                    _isButtonPushed = false;
                                });
                            });
                        },
                    );
                },
              ),
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, color: Colors.white, size: 26),
                onSelected: _setPlaybackSpeed,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
                  const PopupMenuItem<double>(
                    value: 0.5,
                    child: Text('0.5x'),
                  ),
                  const PopupMenuItem<double>(
                    value: 0.75,
                    child: Text('0.75x'),
                  ),
                  const PopupMenuItem<double>(
                    value: 1.0,
                    child: Text('Normal'),
                  ),
                  const PopupMenuItem<double>(
                    value: 1.25,
                    child: Text('1.25x'),
                  ),
                  const PopupMenuItem<double>(
                    value: 1.5,
                    child: Text('1.5x'),
                  ),
                  const PopupMenuItem<double>(
                    value: 2.0,
                    child: Text('2.0x'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}