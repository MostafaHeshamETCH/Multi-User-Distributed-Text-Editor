import 'package:flutter_quill/flutter_quill.dart';

import '../../../models/models.dart';
import '../../controller_state_base.dart';

/*
  Recaps all the local document data used for caching for each user/node
*/
class DocumentState extends ControllerStateBase {
  const DocumentState({
    required this.id,
    this.documentPageData,
    this.quillDocument,
    this.quillController,
    this.isSavedRemotely =
        false, // saved to database server (and locally) or not yet (if not yet it's saved locally only)
    AppError? error,
  }) : super(error: error);

  final String id;
  final DocumentPageData? documentPageData;
  final Document? quillDocument;
  final QuillController? quillController;
  final bool isSavedRemotely;

  @override
  List<Object?> get props => [id, error];

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
