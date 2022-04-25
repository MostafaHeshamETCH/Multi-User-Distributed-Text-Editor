import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants.dart';

// just organize providers for easy access
abstract class Dependency {
  static Provider<Client> get client => _clientProvider;
  static Provider<Database> get database => _databaseProvider;
  static Provider<Account> get account => _accountProvider;
  static Provider<Realtime> get realtime => _realtimeProvider;
}

// clients that comes from appWrite
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

// for reacting to real-time events
final _realtimeProvider =
    Provider<Realtime>((ref) => Realtime(ref.read(_clientProvider)));
