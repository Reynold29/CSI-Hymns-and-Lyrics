import 'dart:convert'; 
import 'package:flutter/services.dart';

class Keerthane {
  final int number;
  final String title; 
  final String signature;
  final String lyrics;
  final String? kannadaLyrics;

  Keerthane({
    required this.number,
    required this.title, 
    required this.signature,
    required this.lyrics,
    required this.kannadaLyrics,
  });
}

Future<List<Keerthane>> loadKeerthane() async {
  final String jsonData = await rootBundle.loadString('lib/assets/keerthane_data.json');
  final data = jsonDecode(jsonData) as List<dynamic>;

  return data.map((item) => Keerthane(
       number: item['number'],
       title: item['title'],
       signature: item['signature'],
       lyrics: item['lyrics'],
       kannadaLyrics: item['kannadaLyrics'] 
    )).toList();
}