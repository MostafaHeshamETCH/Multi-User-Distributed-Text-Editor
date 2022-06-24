import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app.dart';
import '../app/constants.dart';
import '../app/providers.dart';
import '../models/models.dart';
import 'repositories.dart';

final _databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository(ref.read);
});

class DatabaseRepository with RepositoryExceptionMixin {
  DatabaseRepository(this._read);

  final Reader _read;

  // bool isOffline = false;

  static Provider<DatabaseRepository> get provider =>
      _databaseRepositoryProvider;

  Realtime get _realtime => _read(Dependency.realtime);

  Database get _database => _read(Dependency.database);

// calls _createPageAndDelta wrapped in an exception handler, given the owner and the id
  Future<void> createNewPage({
    required String documentId,
    required String owner,
  }) async {
    return exceptionHandler(
        _createPageAndDelta(owner: owner, documentId: documentId));
  }

  // creates 2 documents: 1 for pages and another for delta
  Future<void> _createPageAndDelta({
    required String documentId,
    required String owner,
  }) async {
    Future.wait([
      _database.createDocument(
        collectionId: CollectionNames.pages,
        documentId: documentId,
        data: {
          'owner': owner,
          'title': null,
          'content': null,
        },
      ),
      _database.createDocument(
        collectionId: CollectionNames.delta,
        documentId: documentId,
        data: {
          'delta': null,
          'user': null,
          'deviceId': null,
        },
      ),
    ]);
  }

  //
  Future<DocumentPageData> getPage({
    required String documentId,
  }) {
    return exceptionHandler(_getPage(documentId));
  }

  // Private method to get the document by id from the database
  Future<DocumentPageData> _getPage(String documentId) async {
    // get the document from database
    // TODO: read from both databases, check if one up, read else check the other
    final doc = await _database.getDocument(
      collectionId: CollectionNames.pages,
      documentId: documentId,
    );
    // return document by passing the data to fromMap()
    return DocumentPageData.fromMap(doc
        .data); // map string dynamic, takes the title from map and puts it as title,
    // then gets the json and extracts the delta from json (content is delta)
  }

  // update the page by passing the document id and new document page data, to which the method toMap() is called
  Future<void> updatePage(
      {required String documentId,
      required DocumentPageData documentPage}) async {
    return exceptionHandler(
      _database.updateDocument(
        collectionId: CollectionNames.pages,
        documentId: documentId,
        data: documentPage.toMap(),
      ),
    );
  }

  // made to allow real-time changes
  Future<void> updateDelta({
    // pass as arguments the id and the changes made to the file (deltaData)
    required String pageId,
    required DeltaData deltaData,
  }) {
    return exceptionHandler(
      _database.updateDocument(
        // pass the collection and document id and the changes made (delta) to update document
        collectionId: CollectionNames.delta,
        documentId: pageId,
        data: deltaData.toMap(),
      ),
    );
  }

  // subscribe to the database collection containing the document data
  // in AppWrite database server running on Docker
  // return a stream of realtime subscription events
  RealtimeSubscription subscribeToPage({required String pageId}) {
    try {
      return _realtime // getter uses riverpod read to get real-time dependencies
          .subscribe([
        '${CollectionNames.deltaDocumentsPath}.$pageId'
      ]); // path to what user desires to subscribe to
    } on AppwriteException catch (e) {
      logger.warning(e.message, e);
      throw RepositoryException(
          message: e.message ?? 'An undefined error occurred');
    } on Exception catch (e, st) {
      logger.severe('Error subscribing to page changes', e, st);
      throw RepositoryException(
          message: 'Error subscribing to page changes',
          exception: e,
          stackTrace: st);
    }
  }
}
