import 'package:docufind/utils/read_aloud.dart';
import 'package:docufind/utils/utils.dart';
import 'package:docufind/widgets/overlay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

OverlayEntry showContextMenu(
    BuildContext context, PdfTextSelectionChangedDetails details, clearSelection) {
  // final OverlayState _overlayState = Overlay.of(context)!;
  OverlayEntry? _overlayEntry;
  void setClipBoardData(details) {
    Clipboard.setData(ClipboardData(text: details.selectedText));
    clearSelection();
  }
  void launchGoogle(details) {
    launchUrl_(generateGoogleSearchUrl(details.selectedText.toString()));
  }
  void readAloudSelectedText(details) {
    readAloud(context, details.selectedText.toString());
  }


  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        OverLayButton(
            text: "Copy",
            details: details,
            upFromGlobalCenter: 135,
            downFromGlobalCenter: 20,
            actions: setClipBoardData,
        ),
        OverLayButton(
          text: "Google",
          details: details,
          upFromGlobalCenter: 95,
          downFromGlobalCenter: 60,
          actions: launchGoogle,
        ),
        OverLayButton(
            text: "Speech",
            details: details,
            upFromGlobalCenter: 55,
            downFromGlobalCenter: 100,
            actions: readAloudSelectedText,
        ),
      ],
    ),
  );
  return _overlayEntry!;
}
