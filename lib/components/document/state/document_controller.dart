import 'dart:async';
kimport 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app.dart';
import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';
import 'document_state.dart';

// to identify the provider
final _documentProvider =
    StateNotifierProvider.family<DocumentController, DocumentState, String>( // family creates a map of providers
  (ref, documentId) => DocumentController(
    ref.read,
    documentId: documentId,
  ),
);

// create a new document controller, given the id
class DocumentController extends StateNotifier<DocumentState> {
  final _deviceId = const Uuid().v4(); // to be used in real-time changes, to store per change identidying the device 

  // used to make a small delay between saves, so we don't save too often remotely and jam the database
  Timer? _debounce;

  DocumentController(this._read, {required String documentId})
      : super(
          DocumentState(id: documentId),
        ) {
    _setupDocument();
    _setupListeners(); // listen to real-time changes and make them onto db
  }

  late final StreamSubscription<dynamic>? documentListener; // document listener (local changes)
  late final StreamSubscription<dynamic>? realtimeListener; // real-time listener (remote changes)

  static StateNotifierProviderFamily<DocumentController, DocumentState, String>
      get provider => _documentProvider;

  static AlwaysAliveProviderBase<DocumentController> notifier(
          String documentId) =>
      provider(documentId).notifier;

  final Reader _read;

  // to get document
  Future<void> _setupDocument() async {
    // get document by id to be found and displayed b y quill editor onto the user interface
    try {
      final docPageData = await _read(Repository.database).getPage(
        documentId: state.id,
      );
      late final Document quillDoc;
      // check on content, whether empty or not
      if (docPageData.content.isEmpty) {
        quillDoc = Document()..insert(0, ''); // quill document created at index 0
      } else {
        // set quill document to delta content
        quillDoc = Document.fromDelta(docPageData.content);
      }

      // quill controller created for the new document and we set the current position in the document using a pointing cursor.
      final controller = QuillController(
        document: quillDoc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      // used to update the state currently in
      state = state.copyWith(
        documentPageData: docPageData,
        quillDocument: quillDoc,
        quillController: controller,
        isSavedRemotely: true,
      );

      // this listener is placed to force the controller
      // to be updated each time any new text is changed to the document.
      state.quillController?.addListener(_quillControllerUpdate);

      // This one listens to the whole document to broadcast only remote changes
      documentListener = state.quillDocument?.changes.listen((event) {
        final delta = event.item2;
        final source = event.item3;

        if (source != ChangeSource.LOCAL) {
          // do not broadcast remote changes only local ones
          // user only broadcast their local cached changes and listens
          // for remote changes but do not broadcast them
          return; // return when the source is not local, so it's not broadcasted
        }
        // send real-time (local) changes to all users to be updated
        _broadcastDeltaUpdate(delta);
      });
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }

  // set up listeners 
  Future<void> _setupListeners() async {
    final subscription =  // subscribe to page that listens to real time changes to the remote server
        _read(Repository.database).subscribeToPage(pageId: state.id);
    // listen to a stream of realtime events that occurs in the document to
    // reflect all these changes at realtime to all users
    realtimeListener = subscription.stream.listen( // gives a stream subscription to listen to
      (event) { // every time the document changes
        final dId = event.payload['deviceId']; // get the device id from the payload
        if (_deviceId != dId) {
          late final delta; 
          try {
            delta = Delta.fromJson(jsonDecode(event.payload['delta'])); // create delta from json for changes made in the document
            // and decode the event payload of delta 
          } catch (e) {
            debugPrint('Error ---> ' + e.toString());
          }
          state.quillController?.compose( // compose to create an update to the core controller
            delta,
            // deals with the cursor change position of each user when more than one
            // users are doing changes in the same line
            state.quillController?.selection ??
                const TextSelection.collapsed(offset: 0),
            ChangeSource
                .REMOTE, // specify that the changes are all remote (from AppWrite database server not locally cached)
          );
        }
      },
    );
  }

  Future<void> _broadcastDeltaUpdate(Delta delta) async {
    // update AppWrite database with the new broadcasted data
    _read(Repository.database).updateDelta( // calls update delta on the repository
      pageId: state.id, // pass in page id
      deltaData: DeltaData( // pass in delta data
        user: _read(AppState.auth).user!.$id, // delta data object created based on the current user
        delta: jsonEncode(delta.toJson()), // & based on the delta changes that happened (passed to the function as a whole)
        deviceId: _deviceId, // & device id 
      ),
    );
  }
  
  // update quill controller, used with a listener 
  void _quillControllerUpdate() {
    // at each update, variable updated to indicate that new content was added that is not saved to database
    state = state.copyWith(isSavedRemotely: false); // db is not up to date
    _debounceSave(); // uses debounce timer
  }

  // debounce time is set to 1 second so not each element updated is saved with a separate update request to database,
  // yet multiple changes are cached locally then saved remotely each 1 second
  void _debounceSave({Duration duration = const Duration(seconds: 1)}) {
    // wait until user stops typing, pause 1 second, then save
    if (_debounce?.isActive ?? false) _debounce?.cancel(); // check if debounce is active, then cancel debounce, to allow the interval pause
    _debounce = Timer(duration, () {
      saveDocumentImmediately();
    });
  }

  // for the document title
  void setTitle(String title) {
    state = state.copyWith(
      documentPageData: state.documentPageData?.copyWith(
        title: title,
      ),
      isSavedRemotely: false,
    ); // save title every 100 ms
    _debounceSave(duration: const Duration(milliseconds: 100));
  }

  // to save the document as soon as it's called
  Future<void> saveDocumentImmediately() async {
    // log the saving of the doc
    logger.info('Saving document: ${state.id}');
    // checks if state is null or document is null 
    if (state.documentPageData == null || state.quillDocument == null) {
      // log error message
      logger.severe('Cannot save document, doc state is empty');
      state = state.copyWith(
        error: AppError(message: 'Cannot save document, state is empty'),
      );
    }
    // set state = to new document state ( includes the changes/delta )
    state = state.copyWith(
      documentPageData: state.documentPageData!
          .copyWith(content: state.quillDocument!.toDelta()),
    );
    try {
      await _read(Repository.database).updatePage(
        documentId: state.id,
        documentPage: state.documentPageData!,
      );
      state = state.copyWith(isSavedRemotely: true); // true as it is saved immediately to database server
    } on RepositoryException catch (e) {
      // error - could not save to database (only saved locally)
      state = state.copyWith(
        error: AppError(message: e.message), // set error equal to the message
        isSavedRemotely: false, // update variable wtohen not saved remotely
      );
    }
  }

  @override
  void dispose() {
    // dispose of the listeners
k8  documentListener?.cancel();
    realtimeListener?.cancel();
    state.quillController?.removeListener(_quillControllerUpdate);
    super.dispose();
  }
}
