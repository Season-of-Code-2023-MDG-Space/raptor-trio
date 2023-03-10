import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:DocuFind/pages/home.dart';
import 'package:DocuFind/pages/file_viewer.dart';


void backToHome(context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),
  );
}

Future<void> openFilePage(context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  print(result);
  if (result != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerPage(fileName: result),
      ),
    );
  }
}