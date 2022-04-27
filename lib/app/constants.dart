import 'package:flutter/material.dart';

const appwriteEndpoint = 'http://localhost/v1';
const appwriteProjectId = '6264b5ab9246c97820e8';

const kPrimaryColor = Color(0xFF041C32);

// Database collection names and paths
abstract class CollectionNames {
  static String get delta => 'delta';
  static String get deltaDocumentsPath => 'collections.$delta.documents';
  static String get pages => 'pages';
  static String get pagesDocumentsPath => 'collections.$pages.documents';
}
