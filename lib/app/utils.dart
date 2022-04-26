import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

// import '../components/controller_state_base.dart';
import 'state/state_base.dart';

final logger = Logger('App');

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    String pre = '';
    if (record.level == Level.INFO) {
      pre = 'INFO: ';
    } else if (record.level == Level.WARNING) {
      pre = 'WARNING: ';
    } else if (record.level == Level.SEVERE) {
      pre = 'ERROR: ';
    }
    debugPrint('$pre   ${record.level.name}: ${record.message}');
    if (record.error != null) {
      debugPrint('👉 ${record.error}');
    }
    if (record.level == Level.SEVERE) {
      debugPrintStack(stackTrace: record.stackTrace);
    }
  });

  // extension RefX on WidgetRef {
  // void errorStateListener(
  //   BuildContext context,
  //   ProviderListenable<StateBase> provider,
  // ) {
  //   listen<StateBase>(provider, ((previous, next) {
  //     final message = next.error?.message;
  //     if (next.error != previous?.error &&
  //         message != null &&
  //         message.isNotEmpty) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text(message)));
  //     }
  //   }));
  // }

  // void errorControllerStateListener(
  //   BuildContext context,
  //   ProviderListenable<ControllerStateBase> provider,
  // ) {
  //   listen<ControllerStateBase>(provider, ((previous, next) {
  //     final message = next.error?.message;
  //     if (next.error != previous?.error &&
  //         message != null &&
  //         message.isNotEmpty) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text(message)));
  //     }
  //   }));
  // }
}
