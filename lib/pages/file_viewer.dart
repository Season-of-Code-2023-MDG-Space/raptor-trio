import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:DocuFind/utils/navigation.dart';
import 'package:DocuFind/utils/search.dart';
import 'package:DocuFind/utils/overlay.dart';

/// Represents Homepage for Navigation
class FileViewerPage extends StatefulWidget {
  final FilePickerResult fileName;
  const FileViewerPage({Key? key, required this.fileName}) : super(key: key);
  @override
  _FileViewerPage createState() =>  _FileViewerPage();
}

class _FileViewerPage extends State<FileViewerPage> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  var fileViewer;
  OverlayEntry? _overlayEntry;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  late bool _showToolbar;
  late bool _showScrollHead;
  late PdfDocument document;
  bool isReadAloud = false;
  String fileText = "";


  /// Ensure the entry history of Text search.
  LocalHistoryEntry? _historyEntry;

  void openFileView(SfPdfViewer newValue) {
    setState(() {
      fileViewer = newValue;
    });
  }

  @override
  void initState() {
    _showToolbar = false;
    _showScrollHead = true;
    openFile();
    super.initState();
  }
  /// Ensure the entry history of text search.
  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  /// Remove history entry for text search.
  void _handleHistoryEntryRemoved() {
    _textSearchKey.currentState?.clearSearch();
    setState(() {
      _showToolbar = false;
    });
    _historyEntry = null;
  }

  void clearSelection() {
    _pdfViewerController.clearSelection();
  }

  void _showContextMenu(context, details, clearSelection) {
    final OverlayState _overlayState = Overlay.of(context)!;
    _overlayEntry = showContextMenu(context, details, clearSelection);
    _overlayState.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showToolbar
          ? AppBar(
        flexibleSpace: SafeArea(
          child: SearchToolbar(
            key: _textSearchKey,
            showTooltip: true,
            controller: _pdfViewerController,
            onTap: (Object toolbarItem) async {
              if (toolbarItem.toString() == 'Cancel Search') {
                setState(() {
                  _showToolbar = false;
                  _showScrollHead = true;
                  if (Navigator.canPop(context)) {
                    Navigator.maybePop(context);
                  }
                });
              }
              if (toolbarItem.toString() == 'noResultFound') {
                setState(() {
                  _textSearchKey.currentState?.showToast = true;
                });
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  _textSearchKey.currentState?.showToast = false;
                });
              }
            },
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
      )
          : AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () async {backToHome(context);},
        ),
        title: null,
        actions: [IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showScrollHead = false;
              _showToolbar = true;
              _ensureHistoryEntry();
            });
          },
        ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        color: Colors.black26,
        child: Stack(
          children: [
            fileViewer,
            Visibility(
              visible: _textSearchKey.currentState?.showToast ?? false,
              child: Align(
                alignment: Alignment.center,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding:
                      EdgeInsets.only(left: 15, top: 7, right: 15, bottom: 7),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        'No result',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black12,
    );
  }
  //     Future<List<int>> _readDocumentData(String name) async {
  //   final ByteData data = await rootBundle.load('assets/$name');
  //   return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  // }

  Future<void> openFile() async {
    // bool isStorageAccessible = await checkPermission();
    bool isStorageAccessible =true;
    // Permission.manageExternalStorage.request();
    if(isStorageAccessible){
        File file = File(widget.fileName.files.single.path!);
        SfPdfViewer pdfView = SfPdfViewer.file(
          file,
          controller: _pdfViewerController,
          canShowScrollHead: _showScrollHead,
          currentSearchTextHighlightColor: Colors.deepOrange.withOpacity(0.5),
          otherSearchTextHighlightColor: Colors.orange.withOpacity(0.5),
          onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
            if (details.selectedText == null && _overlayEntry != null) {
              _overlayEntry!.remove();
              _overlayEntry = null;
            } else if (details.selectedText != null && _overlayEntry == null) {
              _showContextMenu(context, details, clearSelection);
            }
          },
        );
        openFileView(pdfView);
    }
  }
}