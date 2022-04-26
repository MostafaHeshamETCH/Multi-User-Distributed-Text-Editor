import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'repository_exception.dart';

final _authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read));

class AuthRepository with RepositoryExceptionMixin {
  const AuthRepository(this._reader);

  static Provider<AuthRepository> get provider => _authRepositoryProvider;

  final Reader _reader;

  Account get _account => _reader(Dependency.account);

  // register
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

  // sign in
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

  // sign out
  Future<void> deleteSession({required String sessionId}) {
    return exceptionHandler(
      _account.deleteSession(sessionId: sessionId),
    );
  }
}
