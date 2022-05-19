import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../app/navigation/routes.dart';
import '../../app/providers.dart';
import '../../repositories/repositories.dart';

//Used ConsumerStateful Widget from riverpod to create the interface of the text documents. 
class NewDocumentPage extends ConsumerStatefulWidget {
  const NewDocumentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewDocumentPageState();
}

//A Class that contains the state of the new created document. 
class _NewDocumentPageState extends ConsumerState<NewDocumentPage> {
  // import Uuid that generates a unique identifier to be used per new document
  final _uuid = const Uuid(); //a variable that will store the id of the created document.

  bool showError = false; //a boolean flag that changes states according to errors. It's initially set to false (No Error)

  @override
  void initState() {
    _createNewPage();
    super.initState();
  }

  Future<void> _createNewPage() async {
    final documentId = _uuid.v4(); //_uuid.v4 is like a random id generator
    try {
      // call the method and pass the id and the owner to the repository
      await ref.read(Repository.database).createNewPage(
            documentId: documentId,
            owner: ref.read(AppState.auth).user!.$id, // owner is the current authenticated user 
            // owner: '627982448ae239ffbd28',
          );

      Routemaster.of(context).push('${AppRoutes.document}/$documentId');
    } on RepositoryException catch (_) {
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showError) {
      return const Center(
        child: Text('An error occurred'),
      );
    } else {
      return const SizedBox();
    }
  }
}
