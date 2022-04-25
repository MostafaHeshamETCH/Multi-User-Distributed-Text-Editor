export 'utils.dart';

import 'package:flutter/material.dart';

class MultiUserTextEditor extends StatelessWidget {
  const MultiUserTextEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-User Text Editor',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Multi-User Text Editor'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
