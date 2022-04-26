export 'utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import 'navigation/routes.dart';

class MultiUserTextEditor extends ConsumerStatefulWidget {
  const MultiUserTextEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MultiUserTextEditorState();
}

class _MultiUserTextEditorState extends ConsumerState<MultiUserTextEditor> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        return routesLoggedOut;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
