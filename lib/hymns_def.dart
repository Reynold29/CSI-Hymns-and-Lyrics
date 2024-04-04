import 'dart:convert'; 
import 'package:flutter/services.dart';

class Hymn {
  final int number;
  final String title; 
  final String signature;
  final String lyrics;
  final String? kannadaLyrics;

  Hymn({
    required this.number,
    required this.title, 
    required this.signature,
    required this.lyrics,
    this.kannadaLyrics,
  });
}

Future<List<Hymn>> loadHymns() async {
  final String jsonData = await rootBundle.loadString('lib/assets/hymns_data.json');
  final data = jsonDecode(jsonData) as List<dynamic>;

  return data.map((item) => Hymn(
       number: item['number'],
       title: item['title'],
       signature: item['signature'],
       lyrics: item['lyrics'],
       kannadaLyrics: item['kannadaLyrics'] 
    )).toList();
}