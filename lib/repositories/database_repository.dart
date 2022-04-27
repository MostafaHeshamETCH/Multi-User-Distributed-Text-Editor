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

  static Provider<DatabaseRepository> get provider =>
      _databaseRepositoryProvider;

  Realtime get _realtime => _read(Dependency.realtime);

  Database get _database => _read(Dependency.database);

  Future<void> createNewPage({
    required String documentId,
    required String owner,
  }) async {
    return exceptionHandler(
        _createPageAndDelta(owner: owner, documentId: documentId));
  }

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

  Future<DocumentPageData> getPage({
    required String documentId,
  }) {
    return exceptionHandler(_getPage(documentId));
  }

  Future<DocumentPageData> _getPage(String documentId) async {
    final doc = await _database.getDocument(
      collectionId: CollectionNames.pages,
      documentId: documentId,
    );
    return DocumentPageData.fromMap(doc.data);
  }

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

  Future<void> updateDelta({
    required String pageId,
    required DeltaData deltaData,
  }) {
    return exceptionHandler(
      _database.updateDocument(
        collectionId: CollectionNames.delta,
        documentId: pageId,
        data: deltaData.toMap(),
      ),
    );
  }

  /*
    subscribe to the database collection containing the document data
    in AppWrite database server running on Docker

    return a stream of realtime subscription events
  */
  RealtimeSubscription subscribeToPage({required String pageId}) {
    try {
      return _realtime
          .subscribe(['${CollectionNames.deltaDocumentsPath}.$pageId']);
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