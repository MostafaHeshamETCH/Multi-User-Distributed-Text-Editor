import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../repositories/repository_exception.dart';
import '../../controller_state_base.dart';


final _loginControllerProvider =
    StateNotifierProvider<LoginController, ControllerStateBase>(//calls ControllerStateBase from controller_state_base file
  (ref) => LoginController(ref.read),
);

class LoginController extends StateNotifier<ControllerStateBase> {
  LoginController(this._read) : super(const ControllerStateBase());

  static StateNotifierProvider<LoginController, ControllerStateBase>
      get provider => _loginControllerProvider;

  static AlwaysAliveProviderBase<LoginController> get notifier =>
      provider.notifier;

  final Reader _read;
//
  Future<void> createSession({
    required String email,
    required String password,
  }) async {
    try {
      await _read(Repository.auth)
          .createSession(email: email, password: password); //uses the dummy email and password identified in the initial_page.dart file to create a session

      final user = await _read(Repository.auth).get(); //this user variable gets the user object from appwrite

      /// Sets the global app state user. Which takes the data provided in the user variable and passes it to the file auth_state.dart. 
      _read(AppState.auth.notifier).setUser(user);
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}
