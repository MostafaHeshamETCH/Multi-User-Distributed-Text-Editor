import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/* From utils class we're using the logging class for setting up a customized logger used for displaying some messages for the user: 
            - INFO
            - SEVERE
            - WARNING
*/
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
}
