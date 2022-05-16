import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_user_distributed_text_editor/app/constants.dart';
import '../../app/providers.dart';
import 'state/document_controller.dart';

// locally store all documents according to their id,
// also stored in AppWrite elsewhere
final _quillControllerProvider =
    Provider.family<quill.QuillController?, String>((ref, id) {
  final test = ref.watch(DocumentController.provider(id));
  return test.quillController;
});

//This class passes the document ID to a constant variable
//Each document has its own unique id. 
class DocumentPage extends ConsumerWidget {
  const DocumentPage({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  final String documentId;

// This is the design of the text editor itself
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(height: 10),
              _Toolbar(documentId: documentId),
              const SizedBox(height: 5),
              Expanded(
                child: _DocumentEditorWidget(
                  documentId: documentId,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 35,
            right: 20,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  ref.read(AppState.auth.notifier).signOut();
                },
                child: const Text(
                  'Close Document',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// consumer state for widgets to which we pass a document id
class _DocumentEditorWidget extends ConsumerStatefulWidget {
  const _DocumentEditorWidget({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  final String documentId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __DocumentEditorState();
}

class __DocumentEditorState extends ConsumerState<_DocumentEditorWidget> {
  final FocusNode _focusNode = FocusNode(); // allows everything to be wrapped in a gesture detector, returned in line 104
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final quillController =
        ref.watch(_quillControllerProvider(widget.documentId)); // ref.watch gets the document.id to be stored in quillCotroller
    // check if null, meaning no id
    if (quillController == null) {
      return const Center(child: CircularProgressIndicator()); // call/implement CircularProgressIndicator symbol for loading
    }

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          // check if b is pressed, then make content bold
          if (event.data.isControlPressed && event.character == 'b' ||
              event.data.isMetaPressed && event.character == 'b') {
            if (quillController
                .getSelectionStyle()
                .attributes
                .keys
                .contains('bold')) {
              quillController.formatSelection(
                  quill.Attribute.clone(quill.Attribute.bold, null));
            } else {
              quillController.formatSelection(quill.Attribute.bold);
            }
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF041C32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Card(
            elevation: 7,
            child: Padding(
              padding: const EdgeInsets.all(86.0),
              child: quill.QuillEditor( // allows us to do rich text editting 
                controller: quillController, //this calls the quillcontroller provider implemented above. 
                scrollController: _scrollController,
                scrollable: true,
                focusNode: _focusNode,
                autoFocus: false,
                readOnly: false,
                expands: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  final String documentId;

//Displays the document ID on the document's page. 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // allows urls with different ids to contain corresponding text at the same time, cached at the client side
    final quillController = ref.watch(_quillControllerProvider(documentId));

    // for loading or errors
    if (quillController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // test editor toolbar options
    return quill.QuillToolbar.basic(
      controller: quillController,
      iconTheme: const quill.QuillIconTheme(
        iconSelectedFillColor: kPrimaryColor,
      ),
      multiRowsDisplay: false,
      showAlignmentButtons: false,
      showBackgroundColorButton: false,
      showRedo: false,
      showUndo: false,
      showCameraButton: false,
      showVideoButton: false,
      showClearFormat: false,
      showImageButton: false,
      showCodeBlock: false,
      showIndent: false,
      showLink: false,
      showCenterAlignment: false,
      showListBullets: false,
      showListCheck: false,
      showDirection: false,
      showInlineCode: false,
      showListNumbers: false,
      showQuote: false,
      showSmallButton: false,
      showHeaderStyle: false,
      showDividers: false,
      showJustifyAlignment: false,
      showStrikeThrough: false,
      showColorButton: false,
    );
  }
}
