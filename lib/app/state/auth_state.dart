import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_error.dart';
import '../../repositories/repository_exception.dart';
import '../providers.dart';
import '../utils.dart';
import 'state_base.dart';

final _authServiceProvider = StateNotifierProvider<AuthService, AuthState>(
    (ref) => AuthService(ref.read));

// create class to update the state of the notifier (Auth) at any time from one place
// Authentication Service, takes info from authentication provider
class AuthService extends StateNotifier<AuthState> {
  AuthService(this._read) // initialize the constructor and pass the auth state
      //isLoading set to true as this is only called when we're initiating an authentication
      : super(const AuthState.unauthenticated(isLoading: true)) {
    refresh(); // call the refresh method which does the initial authentication checks
  }

  static StateNotifierProvider<AuthService, AuthState> get provider =>
      _authServiceProvider;

  final Reader _read; // to read auth state

  Future<void> refresh() async {
    try {
      final user = await _read(Repository.auth).get();
      setUser(user);
    } on RepositoryException catch (_) { //this exception is raised if the entered user is unauthorized 
      logger.info('Not authenticated');
      state = const AuthState.unauthenticated();
    }
  }

  void setUser(User user) {
    logger.info('Authentication successful, setting $user'); //saves the info of the entered user when the authentication is true. 
    state = state.copyWith(user: user, isLoading: false); //takes the data provided in the user variable from the login_controller.dart file. 
  }

  Future<void> signOut() async {
    try {
      await _read(Repository.auth).deleteSession(sessionId: 'current'); //gets the ID of the current session and deletes it after the user signs out. 
      logger.info('Sign out successful');
      state = const AuthState.unauthenticated(); //after the session is deleted, the user gets unauthenticated
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}

class AuthState extends StateBase {
  final User? user;
  final bool isLoading; // to visualize auth loading in UI

  const AuthState({ 
    this.user, // takes for argument, the user
    this.isLoading = false, // takes as well isLoading value, initially set to false
    AppError? error, // and can take an app error, if specified 
  }) : super(error: error);

  const AuthState.unauthenticated({this.isLoading = false}) // name constructor
      : user = null,
        super(error: null);

  @override
  List<Object?> get props => [user, isLoading, error]; // props from equatable, to compare user, isLoading and error

  bool get isAuthenticated => user != null; // to specify if we are authenticated or not

  AuthState copyWith({ // function to create new objects from existing ones 
    User? user,
    bool? isLoading,
    AppError? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}
