import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'repository_exception.dart';

final _authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read));

// class is create with three methods: create(), createSession() and deleteSession()
// class calls RepositoryExceptionMixin and returns exception handler
class AuthRepository with RepositoryExceptionMixin {
  const AuthRepository(this._reader);

  static Provider<AuthRepository> get provider => _authRepositoryProvider;

  // constant that makes it easier to read the value of a provider anywhere in the application
  final Reader _reader;

  Account get _account => _reader(Dependency.account);

  // for the registration module, create the user
  // _account => pre-implemented class in implemented in AppWrite
  Future<User> create({
    required String email,
    required String password,
    required String name,
  }) {
    return exceptionHandler(
      _account.create(
        // unique is auto-generated id from AppWrite
        userId: 'unique()',
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  // sign in, used for authentication
  // create a session with account identified by its email and password
  Future<Session> createSession({
    required String email,
    required String password,
  }) {
    return exceptionHandler(
      _account.createSession(email: email, password: password),
    );
  }

  Future<User> get() {
    return exceptionHandler(
      _account.get(),
    );
  }

  // sign out and delete the session by id
  Future<void> deleteSession({required String sessionId}) {
    return exceptionHandler(
      _account.deleteSession(sessionId: sessionId),
    );
  }
}
