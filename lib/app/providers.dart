import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/repositories.dart';
import 'constants.dart';
import 'state/state.dart';

// Organize providers for easy access
abstract class Dependency {
  static Provider<Client> get client => _clientProvider;
  static Provider<Database> get database => _databaseProvider;
  static Provider<Account> get account => _accountProvider;
  static Provider<Realtime> get realtime => _realtimeProvider;
}

// AuthRepo Provider
// auth object can be used to get user id and all other info
abstract class Repository {
  static Provider<AuthRepository> get auth =>
      AuthRepository.provider; // expose auth provider
  static Provider<DatabaseRepository> get database =>
      DatabaseRepository.provider; // expose database provider
}

// expose auth provider to listen on auth state
abstract class AppState {
  static StateNotifierProvider<AuthService, AuthState> get auth =>
      AuthService.provider;
}

// create a client provider, that comes from appWrite
final _clientProvider = Provider<Client>(
  (ref) => Client()
    ..setProject(appwriteProjectId)
    ..setSelfSigned(status: true)
    ..setEndpoint(appwriteEndpoint),
);

// for documents
final _databaseProvider =
    Provider<Database>((ref) => Database(ref.read(_clientProvider)));

// for auth
final _accountProvider = Provider<Account>(
  (ref) => Account(ref.read(_clientProvider)),
);

// for reacting to real-time changes that happen in the database
final _realtimeProvider =
    Provider<Realtime>((ref) => Realtime(ref.read(_clientProvider)));
