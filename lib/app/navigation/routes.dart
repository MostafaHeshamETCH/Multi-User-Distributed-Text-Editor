import 'package:routemaster/routemaster.dart';

import '../../components/auth/auth.dart';
import '../../components/document/document.dart';

const _login = '/login';
const _document = '/document';
const _newDocument = '/newDocument';

//Giving the app access to these routes defined as consts above. 
abstract class AppRoutes {
  static String get document => _document;
  static String get newDocument => _newDocument;
  static String get login => _login;
}

/* When the user is logged out, he/she is redirected to login page. 
*/
final routesLoggedOut = RouteMap(
  onUnknownRoute: (_) => const Redirect(_login),
  routes: {
    _login: (_) => const TransitionPage(
          child: InitialPage(),
        ),
  },
);

/* Defines the flow of the text editor's pages after login: 
   New Document --> checks for doc id --> no id = new document 
   existing id = fetches the existing corresponding document. 

*/
final routesLoggedIn = RouteMap(
  onUnknownRoute: (_) => const Redirect(_newDocument),
  
  routes: {
    _newDocument: (_) => const TransitionPage(child: NewDocumentPage()),
    '$_document/:id': (info) {
      // variable that checks if the id given exists
      final docId = info.pathParameters['id'];
      // if not create a new id by redirecting to a new document
      if (docId == null) {
        return const Redirect(_newDocument);
      }
      return TransitionPage(
        child: DocumentPage(documentId: docId),
      );
    },
  },
);
