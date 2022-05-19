import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_quill/flutter_quill.dart';


class DocumentPageData extends Equatable {
  final String title; // document data has a tilte of type string
  final Delta content; // document data has content, saved in the form of delta (changes)
  /*
    Delta is the concept of individual changes implemented by Quill, the text-editor package we used.
    Each delta will be used extensively to broadcast realtime changes to multi-users.
  */

  const DocumentPageData({
    required this.title,
    required this.content,
  });

  // to map, encodes document content and sends it, along with the document title
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': jsonEncode(content.toJson()),
    };
  }

  // from map, checks if document contains content, and decodes the content to be displayed to the user, along with the title
  factory DocumentPageData.fromMap(Map<String, dynamic> map) {
    final contentJson =
        (map['content'] == null) ? [] : jsonDecode(map['content']);
    return DocumentPageData(
      title: map['title'] ?? '',
      content: Delta.fromJson(contentJson),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentPageData.fromJson(String source) =>
      DocumentPageData.fromMap(json.decode(source));

  @override
  List<Object?> get props => [title, content];

  DocumentPageData copyWith({
    String? title,
    Delta? content,
  }) {
    return DocumentPageData(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
