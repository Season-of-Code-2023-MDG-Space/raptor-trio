import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:docufind/utils/constants.dart';

class OverLayButton extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final PdfTextSelectionChangedDetails details;
  final int upFromGlobalCenter;
  final int downFromGlobalCenter;
  final actions;

  const OverLayButton(
      {
        Key? key,
        required this.text,
        required this.details,
        required this.upFromGlobalCenter,
        required this.downFromGlobalCenter,
        this.actions,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: details.globalSelectedRegion!.center.dy > 200?
      details.globalSelectedRegion!.center.dy - upFromGlobalCenter
          :details.globalSelectedRegion!.center.dy + downFromGlobalCenter,
      left: details.globalSelectedRegion!.bottomLeft.dx>10?
      details.globalSelectedRegion!.bottomLeft.dx
          :details.globalSelectedRegion!.bottomCenter.dx,
      height: 40,
      width: 100,
      child: ElevatedButton(
        onPressed: () {actions(details);},
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
        child: Text(text, style: Constants.textStyle),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}