import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../widgets/overlay.dart';

/// Represents Homepage for Navigation
class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  var fileViewer;
  bool showFile = false;
  OverlayEntry? _overlayEntry;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  late bool _showToolbar;
  late bool _showScrollHead;

  /// Ensure the entry history of Text search.
  LocalHistoryEntry? _historyEntry;

  void openFileView(SfPdfViewer newValue) {
    setState(() {
      fileViewer = newValue;
      showFile = true;
    });
  }

  void backToHome() {
    setState(() {
      fileViewer = null;
      showFile = false;
    });
  }

  @override
  void initState() {
    _showToolbar = false;
    _showScrollHead = true;
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
                  _textSearchKey.currentState?._showToast = true;
                });
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  _textSearchKey.currentState?._showToast = false;
                });
              }
            },
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
      )
          : AppBar(
        leading: showFile? IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {backToHome();},
        ):null,
        title: showFile==false?Text(
          'DocuFind',
          style: TextStyle(color: Colors.white),
        ):Text(""), //Hide Title while displaying file
        actions: [showFile?
          IconButton(
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
          ):Text(""),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        color: Colors.black26,
        child: this.showFile == false
            ? ElevatedButton(
          child: Text('Open File', style: TextStyle(color:Colors.black,),),
          onPressed: () async {openFile();},
        )
            : Stack(
          children: [
            fileViewer,
            Visibility(
              visible: _textSearchKey.currentState?._showToast ?? false,
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

  Future<bool> checkPermission() async {
    Permission storagePermission = Permission.storage;
    if (await storagePermission.isGranted) {
      return true;
    } else if (await storagePermission.isPermanentlyDenied) {
      return false;
    } else {
      await storagePermission.request();
      storagePermission = Permission.storage;
      return (await storagePermission.isPermanentlyDenied ||
          await storagePermission.isDenied)
          ? false
          : true;
    }
  }

  Future<void> openFile() async {
    // bool isStorageAccessible = await checkPermission();
    bool isStorageAccessible =true;
    // Permission.manageExternalStorage.request();
    if(isStorageAccessible){
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
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
      } else {
        // User canceled the picker
      }
      // _pdfViewerKey.currentState?.openBookmarkView();

    }
  }
}

/// Signature for the [SearchToolbar.onTap] callback.
typedef SearchTapCallback = void Function(Object item);

/// SearchToolbar widget
class SearchToolbar extends StatefulWidget {
  ///it describe the search toolbar constructor
  SearchToolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    Key? key,
  }) : super(key: key);

  /// Indicates whether the tooltip for the search toolbar items need to be shown or not.
  final bool showTooltip;

  /// An object that is used to control the [SfPdfViewer].
  final PdfViewerController? controller;

  /// Called when the search toolbar item is selected.
  final SearchTapCallback? onTap;

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

/// State for the SearchToolbar widget
class SearchToolbarState extends State<SearchToolbar> {
  /// Indicates whether search is initiated or not.
  bool _isSearchInitiated = false;

  /// Indicates whether search toast need to be shown or not.
  bool _showToast = false;

  ///An object that is used to retrieve the current value of the TextField.
  final TextEditingController _editingController = TextEditingController();

  /// An object that is used to retrieve the text search result.
  PdfTextSearchResult _pdfTextSearchResult = PdfTextSearchResult();

  ///An object that is used to obtain keyboard focus and to handle keyboard events.
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode?.requestFocus();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusNode?.dispose();
    _pdfTextSearchResult.removeListener(() {});
    super.dispose();
  }

  ///Clear the text search result
  void clearSearch() {
    _isSearchInitiated = false;
    _pdfTextSearchResult.clear();
  }

  ///Display the Alert dialog to search from the beginning
  void _showSearchAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(0),
          title: Text('Search Result', style: TextStyle(color: Colors.white)),
          content: Container(
              width: 328.0,
              child: Text(
                'No more occurrences found. Would you like to continue to search from the beginning?',
                style: TextStyle(color: Colors.white),
              )),
          backgroundColor: Colors.black,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _pdfTextSearchResult.nextInstance();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'YES',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.87),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _pdfTextSearchResult.clear();
                  _editingController.clear();
                  _isSearchInitiated = false;
                  focusNode?.requestFocus();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'NO',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.87),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white.withOpacity(0.54),
              size: 24,
            ),
            onPressed: () {
              widget.onTap?.call('Cancel Search');
              _isSearchInitiated = false;
              _editingController.clear();
              _pdfTextSearchResult.clear();
            },
          ),
        ),
        Flexible(
          child: TextFormField(
            style: TextStyle(
                color: Colors.white.withOpacity(0.87), fontSize: 16),
            enableInteractiveSelection: false,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            controller: _editingController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Find...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.34)),
            ),
            onChanged: (text) {
              if (_editingController.text.isNotEmpty) {
                setState(() {});
              }
            },
            onFieldSubmitted: (String value) {
              if (kIsWeb) {
                _pdfTextSearchResult =
                    widget.controller!.searchText(_editingController.text);
                if (_pdfTextSearchResult.totalInstanceCount == 0) {
                  widget.onTap?.call('noResultFound');
                }
                setState(() {});
              } else {
                _isSearchInitiated = true;
                _pdfTextSearchResult =
                    widget.controller!.searchText(_editingController.text);
                _pdfTextSearchResult.addListener(() {
                  if (super.mounted) {
                    setState(() {});
                  }
                  if (!_pdfTextSearchResult.hasResult &&
                      _pdfTextSearchResult.isSearchCompleted) {
                    widget.onTap?.call('noResultFound');
                  }
                });
              }
            },
          ),
        ),
        Visibility(
          visible: _editingController.text.isNotEmpty,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: Color.fromRGBO(255, 255, 255, 0.54),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _editingController.clear();
                  _pdfTextSearchResult.clear();
                  widget.controller!.clearSelection();
                  _isSearchInitiated = false;
                  focusNode!.requestFocus();
                });
                widget.onTap!.call('Clear Text');
              },
              tooltip: widget.showTooltip ? 'Clear Text' : null,
            ),
          ),
        ),
        Visibility(
          visible:
          !_pdfTextSearchResult.isSearchCompleted && _isSearchInitiated,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Visibility(
          visible: _pdfTextSearchResult.hasResult,
          child: Row(
            children: [
              Text(
                '${_pdfTextSearchResult.currentInstanceIndex}',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Text(
                ' of ',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Text(
                '${_pdfTextSearchResult.totalInstanceCount}',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.navigate_before,
                    color: Color.fromRGBO(255, 255, 255, 0.54),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _pdfTextSearchResult.previousInstance();
                    });
                    widget.onTap!.call('Previous Instance');
                  },
                  tooltip: widget.showTooltip ? 'Previous' : null,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.navigate_next,
                    color: Color.fromRGBO(255, 255, 255, 0.54),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_pdfTextSearchResult.currentInstanceIndex ==
                          _pdfTextSearchResult.totalInstanceCount &&
                          _pdfTextSearchResult.currentInstanceIndex != 0 &&
                          _pdfTextSearchResult.totalInstanceCount != 0 &&
                          _pdfTextSearchResult.isSearchCompleted) {
                        _showSearchAlertDialog(context);
                      } else {
                        widget.controller!.clearSelection();
                        _pdfTextSearchResult.nextInstance();
                      }
                    });
                    widget.onTap!.call('Next Instance');
                  },
                  tooltip: widget.showTooltip ? 'Next' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}