import 'package:routemaster/routemaster.dart';

import '../../components/auth/auth.dart';
import '../../components/document/document.dart';

const _login = '/login';
const _document = '/document';
const _newDocument = '/newDocument';

abstract class AppRoutes {
  static String get document => _document;
  static String get newDocument => _newDocument;
  static String get login => _login;
}

final routesLoggedOut = RouteMap(
  onUnknownRoute: (_) => const Redirect(_login),
  routes: {
    _login: (_) => const TransitionPage(
          child: InitialPage(),
        ),
  },
);

final routesLoggedIn = RouteMap(
  onUnknownRoute: (_) => const Redirect(_newDocument),
  routes: {
    _newDocument: (_) => const TransitionPage(child: NewDocumentPage()),
    '$_document/:id': (info) {
      final docId = info.pathParameters['id'];
      if (docId == null) {
        return const Redirect(_newDocument);
      }
      return TransitionPage(
        child: DocumentPage(documentId: docId),
      );
    },
  },
);
