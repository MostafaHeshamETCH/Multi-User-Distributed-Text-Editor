import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app.dart';
import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';
import 'document_state.dart';

final _documentProvider =
    StateNotifierProvider.family<DocumentController, DocumentState, String>(
  (ref, documentId) => DocumentController(
    ref.read,
    documentId: documentId,
  ),
);

class DocumentController extends StateNotifier<DocumentState> {
  final _deviceId = const Uuid().v4();

  // used to make a small delay between saves, so we don't save too often remotely and jam the database
  Timer? _debounce;

  DocumentController(this._read, {required String documentId})
      : super(
          DocumentState(id: documentId),
        ) {
    _setupDocument();
    _setupListeners();
  }

  late final StreamSubscription<dynamic>? documentListener;
  late final StreamSubscription<dynamic>? realtimeListener;

  static StateNotifierProviderFamily<DocumentController, DocumentState, String>
      get provider => _documentProvider;

  static AlwaysAliveProviderBase<DocumentController> notifier(
          String documentId) =>
      provider(documentId).notifier;

  final Reader _read;

  Future<void> _setupDocument() async {
    try {
      final docPageData = await _read(Repository.database).getPage(
        documentId: state.id,
      );

      late final Document quillDoc;
      if (docPageData.content.isEmpty) {
        quillDoc = Document()..insert(0, '');
      } else {
        quillDoc = Document.fromDelta(docPageData.content);
      }

      final controller = QuillController(
        document: quillDoc,
        selection: const TextSelection.collapsed(offset: 0),
      );

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
          return;
        }
        // send RT changes to all users to be updated
        _broadcastDeltaUpdate(delta);
      });
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }

  Future<void> _setupListeners() async {
    final subscription =
        _read(Repository.database).subscribeToPage(pageId: state.id);
    // listen to a stream of realtime events that occurs in the document to
    // reflect all these changes at realtime to all users
    realtimeListener = subscription.stream.listen(
      (event) {
        final dId = event.payload['deviceId'];
        if (_deviceId != dId) {
          late final delta;
          try {
            delta = Delta.fromJson(jsonDecode(event.payload['delta']));
          } catch (e) {
            debugPrint('Error ---> ' + e.toString());
          }
          state.quillController?.compose(
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
    _read(Repository.database).updateDelta(
      pageId: state.id,
      deltaData: DeltaData(
        user: _read(AppState.auth).user!.$id,
        delta: jsonEncode(delta.toJson()),
        deviceId: _deviceId,
      ),
    );
  }

  void _quillControllerUpdate() {
    state = state.copyWith(isSavedRemotely: false);
    _debounceSave();
  }

  // debounce time is set to 2 seconds so not each element updated is saved with a separate update request to database,
  //yet multiple changes are cached locally then saved remotely each 2 seconds
  void _debounceSave({Duration duration = const Duration(seconds: 1)}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(duration, () {
      saveDocumentImmediately();
    });
  }

  void setTitle(String title) {
    state = state.copyWith(
      documentPageData: state.documentPageData?.copyWith(
        title: title,
      ),
      isSavedRemotely: false,
    );
    _debounceSave(duration: const Duration(milliseconds: 100));
  }

  Future<void> saveDocumentImmediately() async {
    logger.info('Saving document: ${state.id}');
    if (state.documentPageData == null || state.quillDocument == null) {
      logger.severe('Cannot save document, doc state is empty');
      state = state.copyWith(
        error: AppError(message: 'Cannot save document, state is empty'),
      );
    }
    state = state.copyWith(
      documentPageData: state.documentPageData!
          .copyWith(content: state.quillDocument!.toDelta()),
    );
    try {
      await _read(Repository.database).updatePage(
        documentId: state.id,
        documentPage: state.documentPageData!,
      );
      state = state.copyWith(
          isSavedRemotely:
              true); // true as it is saved immediately to database server
    } on RepositoryException catch (e) {
      state = state.copyWith(
        error: AppError(message: e.message),
        isSavedRemotely: false,
      );
    }
  }

  @override
  void dispose() {
    documentListener?.cancel();
    realtimeListener?.cancel();
    state.quillController?.removeListener(_quillControllerUpdate);
    super.dispose();
  }
}
