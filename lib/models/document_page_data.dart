import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DocumentPageData extends Equatable {
  final String title;
  final Delta content;
  /*
    Delta is the concept of individual changes implemented by Quill, the text-editor package we used.
    Each delta will be used extensively to broadcast realtime changes to multi-users.
  */

  const DocumentPageData({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': jsonEncode(content.toJson()),
    };
  }

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
