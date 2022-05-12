import 'dart:async';

import 'package:appwrite/appwrite.dart';

import '../app/utils.dart';

// for easier error handling when managing the UI
// allows us to pass in a message, an exception and a stack trace to the function
class RepositoryException implements Exception {
  const RepositoryException(
      {required this.message, this.exception, this.stackTrace});

  final String message;
  final Exception? exception;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return "RepositoryException: $message)";
  }
}

// listen to RepositoryException instead of AppWriteException to know what causes the error better
mixin RepositoryExceptionMixin { // returns a class whos methods can be accessed by other classes
  Future<T> exceptionHandler<T>( // use Future to handle asynchronous operations
    FutureOr computation, {
    String unknownMessage = 'Repository Exception',
  }) async {
    try {
      return await computation;
    } on AppwriteException catch (e) {
      logger.warning(e.message, e);
      throw RepositoryException(
          message: e.message ?? 'An undefined error occurred');
    } on Exception catch (e, st) {
      logger.severe(unknownMessage, e, st);
      throw RepositoryException(
          message: unknownMessage, exception: e, stackTrace: st);
    }
  }
}
