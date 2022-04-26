export 'utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import 'navigation/routes.dart';
import 'providers.dart';

final _isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(AppState.auth).isAuthenticated);

final _isAuthLoading =
    Provider<bool>((ref) => ref.watch(AppState.auth).isLoading);

class MultiUserTextEditor extends ConsumerStatefulWidget {
  const MultiUserTextEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MultiUserTextEditorState();
}

class _MultiUserTextEditorState extends ConsumerState<MultiUserTextEditor> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_isAuthLoading);
    if (isLoading) {
      return Container(
        color: Colors.white,
      );
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        final isAuthenticated = ref.watch(_isAuthenticatedProvider);
        return isAuthenticated ? routesLoggedIn : routesLoggedOut;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
