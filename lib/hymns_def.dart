import 'package:flutter/services.dart'; 
import 'dart:convert';

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

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'signature': signature,
    'lyrics': lyrics,
    'kannadaLyrics': kannadaLyrics 
  }; 

  factory Hymn.fromJson(Map<String, dynamic> json) => Hymn(
    number: json['number'],
    title: json['title'],
    signature: json['signature'],
    lyrics: json['lyrics'],
    kannadaLyrics: json['kannadaLyrics'] 
  );
}

Future<List<Hymn>> loadHymns() async {
  final String jsonData = await rootBundle.loadString('lib/assets/hymns_data.json');
  final data = jsonDecode(jsonData) as List<dynamic>;

  return data.map((item) => Hymn.fromJson(item)).toList();
}

