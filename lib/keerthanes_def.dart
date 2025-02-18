import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.kannadaLyrics,
  });

  factory Keerthane.fromJson(Map<String, dynamic> json) => Keerthane(
    number: json['number'],
    title: json['title'],
    signature: json['signature'],
    lyrics: json['lyrics'],
    kannadaLyrics: json['kannadaLyrics'] 
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'signature': signature,
    'lyrics': lyrics,
    'kannadaLyrics': kannadaLyrics
  };
}

Future<List<Keerthane>> loadKeerthane() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonData = prefs.getString('keerthaneData');

  if (jsonData != null) {
    final data = jsonDecode(jsonData) as List<dynamic>;
    return data.map((item) => Keerthane.fromJson(item)).toList();
  } else {
    final String jsonData = await rootBundle.loadString('lib/assets/keerthane_data.json');
    final data = jsonDecode(jsonData) as List<dynamic>;
    return data.map((item) => Keerthane.fromJson(item)).toList();
  }
}

Future<List<Keerthane>> loadKeerthaneFromNetwork(String jsonData) async {
  try {
    final data = jsonDecode(jsonData) as List<dynamic>;
    return data.map((item) => Keerthane.fromJson(item)).toList();
  } catch (e) {
    print("Error parsing keerthane data: $e");
    return [];
  }
}
