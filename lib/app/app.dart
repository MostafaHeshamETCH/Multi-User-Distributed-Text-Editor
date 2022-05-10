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

/*
  From Riverpod we created a new stateful consumer widget. 
  This widget is used to generate the white window used as a background. 
*/

// 
class _MultiUserTextEditorState extends ConsumerState<MultiUserTextEditor> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_isAuthLoading);
    if (isLoading) {
      return Container(
        color: Colors.white,
      );
    }

    /* returns the route of the pages created in the route file based on the output
    of the inline if condition below. If the user is authenticates then the loggedIn
    page will be redirected else the loggedout page will be redirect. 
    
    */
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
