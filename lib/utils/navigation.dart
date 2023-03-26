import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:docufind/pages/home.dart';
import 'package:docufind/pages/file_viewer.dart';


void backToHome(context) {
  context.state.flutterTts.stop();
  if (context.state.overlayEntry != null) {
    context.state.overlayEntry!.remove();
    context.state.overlayEntry = null;
  }
  Navigator.pop(context);
}

Future<void> openFilePage(context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    try {
      context.state.dbHelper.addItem(result.paths[0], result.paths[0]?.split("/").last);
    } catch(err) {
      context.state.dbHelper.updateItem(result.paths[0], result.paths[0]?.split("/").last);
    }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewerPage(fileName: result.paths[0]!),
        ),
      );
    }
  }


Future<void> openFilePageFromHistory(context, String path, String filename) async {
  try {
    context.state.dbHelper.addItem(path, filename);
  } catch(err) {
    context.state.dbHelper.updateItem(path, filename);
  }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerPage(fileName: path),
      ),
    );
}