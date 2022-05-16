import 'package:flutter_quill/flutter_quill.dart';

import '../../../models/models.dart';
import '../../controller_state_base.dart';

/*
  Recaps all the local document data used for caching for each user/node
*/
class DocumentState extends ControllerStateBase {
  const DocumentState({
    // gets the quill document and controller 
    required this.id,
    this.documentPageData,
    this.quillDocument, // 
    this.quillController, // text editor controller
    this.isSavedRemotely =
        false, // saved to database server (and locally - cached) OR not yet (saved locally only)
    AppError? error,
  }) : super(error: error);

  final String id;
  final DocumentPageData? documentPageData;
  final Document? quillDocument;
  final QuillController? quillController;
  final bool isSavedRemotely;

// pass the id and the error message, because we don't want the document 
// to be reactive when the quill document or controller changes
  @override
  List<Object?> get props => [id, error];

// used to update the state easily
  @override
  DocumentState copyWith({
    String? id,
    DocumentPageData? documentPageData,
    Document? quillDocument,
    QuillController? quillController,
    bool? isSavedRemotely,
    AppError? error,
  }) {
    return DocumentState(
      id: id ?? this.id,
      documentPageData: documentPageData ?? this.documentPageData,
      quillDocument: quillDocument ?? this.quillDocument,
      quillController: quillController ?? this.quillController,
      isSavedRemotely: isSavedRemotely ?? this.isSavedRemotely,
      error: error ?? this.error,
    );
  }
}
