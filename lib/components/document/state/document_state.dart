import 'package:flutter_quill/flutter_quill.dart';

import '../../../models/models.dart';
import '../../controller_state_base.dart';

/*
  Recaps all the local document data used for caching for each user/node
*/
class DocumentState extends ControllerStateBase {
  const DocumentState({
    // gets the quill document and controller
    required this.id, // unique id
    this.documentPageData, // content
    this.quillDocument, // the document
    this.quillController, // text editor controller
    this.isSavedRemotely = // boolean value to indicate whether it's saved remotely or not
        false, // saved to database server (and locally - cached) OR not yet (saved locally only)
    this.isOffline = false, // start assuming valid internet connection
    AppError? error,
  }) : super(error: error);

  final String id;
  final DocumentPageData? documentPageData;
  final Document? quillDocument;
  final QuillController? quillController;
  final bool isSavedRemotely;
  final bool isOffline;

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
    bool? isOffline,
    AppError? error,
  }) {
    return DocumentState(
      id: id ?? this.id,
      documentPageData: documentPageData ??
          this.documentPageData, // check if content is not null,
      // then we set it equal to the current value, else we set it to the new value ( adding the changes )
      quillDocument: quillDocument ?? this.quillDocument,
      quillController: quillController ?? this.quillController,
      isSavedRemotely: isSavedRemotely ?? this.isSavedRemotely,
      isOffline: isOffline ?? this.isOffline,
      error: error ?? this.error,
    );
  }
}
