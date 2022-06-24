import 'package:flutter/material.dart';

const appwriteEndpoint = 'https://etch-da.live/v1';
const appwriteProjectId = '627980b0394c14f6497d';

const appwriteEndpointReplica = 'https://etch-da.live/v1';
const appwriteProjectIdReplica = '62b63b2957203e12cafe';

const kPrimaryColor = Color(0xFF041C32);

// Database collection names and paths to be used in repo of database
abstract class CollectionNames {
  static String get delta => 'delta';
  static String get deltaDocumentsPath => 'collections.$delta.documents';
  static String get pages => 'pages';
  static String get pagesDocumentsPath => 'collections.$pages.documents';
}
