import 'package:DocuFind/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

OverlayEntry showContextMenu(
    BuildContext context, PdfTextSelectionChangedDetails details, clearSelection) {
  // final OverlayState _overlayState = Overlay.of(context)!;
  OverlayEntry? _overlayEntry;

  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned(
          top: details.globalSelectedRegion!.center.dy > 200?
          details.globalSelectedRegion!.center.dy - 95:details.globalSelectedRegion!.center.dy + 20,
          left: details.globalSelectedRegion!.bottomLeft.dx>10?
          details.globalSelectedRegion!.bottomLeft.dx:details.globalSelectedRegion!.bottomCenter.dx,
          height: 40,
          width: 100,
          child: ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText));
              print('Text copied to clipboard: ' + details.selectedText.toString());
              clearSelection();
            },
            style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                backgroundColor: Colors.black,
                foregroundColor: Colors.black,
                elevation: 10,
                shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.red)
                )
            ),
            child: Text('Copy', style: TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ),
        Positioned(
          top: details.globalSelectedRegion!.center.dy > 200?
          details.globalSelectedRegion!.center.dy - 55:details.globalSelectedRegion!.center.dy + 60,
          left: details.globalSelectedRegion!.bottomLeft.dx>10?
          details.globalSelectedRegion!.bottomLeft.dx:details.globalSelectedRegion!.bottomCenter.dx,
          height: 40,
          width: 100,
          child: ElevatedButton(
            onPressed: () async {
              final url = generateGoogleSearchUrl(details.selectedText.toString());
              launchUrl_(url);
            },
            style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                backgroundColor: Colors.black,
                foregroundColor: Colors.black,
                elevation: 10,
                shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.red)
                )
            ),
            child: Text('Google', style: TextStyle(color: Colors.white,fontSize: 17)),
          ),
        ),
      ],
    ),
  );
  return _overlayEntry!;
}
