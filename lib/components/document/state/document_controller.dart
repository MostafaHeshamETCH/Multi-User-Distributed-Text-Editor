import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'document_state.dart';

final _documentProvider =
    StateNotifierProvider.family<DocumentController, DocumentState, String>(
  (ref, documentId) => DocumentController(
    ref.read,
    documentId: documentId,
  ),
);

class DocumentController extends StateNotifier<DocumentState> {
  DocumentController(this._read, {required String documentId})
      : super(
          DocumentState(id: documentId),
        ) {
    // each document is identified by an id, that the main idea, sharing docs is build on
    _setupDocument();
  }

  static StateNotifierProviderFamily<DocumentController, DocumentState, String>
      get provider => _documentProvider;

  static AlwaysAliveProviderBase<DocumentController> notifier(
          String documentId) =>
      provider(documentId).notifier;

  final Reader _read;

  Future<void> _setupDocument() async {
    final quillDoc = Document()
      ..insert(0, ''); //insert nothing at index 0 to create a doc using Quill

    final controller = QuillController(
      document: quillDoc,
      selection:
          const TextSelection.collapsed(offset: 0), // start cursor at offset 0
    );

    state = state.copyWith(
      quillDocument: quillDoc,
      quillController: controller,
    );
  }
}
