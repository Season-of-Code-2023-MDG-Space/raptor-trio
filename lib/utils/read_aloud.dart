import 'package:flutter_tts/flutter_tts.dart';

Future<void> readAloud(context, String textToRead) async {
  context.state.flutterTts.speak(textToRead.replaceAll("\n", " "));
}