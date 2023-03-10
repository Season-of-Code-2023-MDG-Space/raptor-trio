import 'package:flutter_tts/flutter_tts.dart';

Future<void> readAloud(String textToRead) async {
  FlutterTts flutterTts = FlutterTts();

  await flutterTts.setLanguage('en-US');
  await flutterTts.setPitch(1);
  await flutterTts.setSpeechRate(0.5);
  print(textToRead.replaceAll("\n", " "));
  flutterTts.speak(textToRead.replaceAll("\n", " "));
}