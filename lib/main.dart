import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import 'app/app.dart';
import 'components/document/state/internet_connection_provider.dart';

//ProviderScope func. is used to set up Riverpod.
void main() {
  setupLogger();

  runApp(const OfflineLoader());
}

class OfflineLoader extends StatefulWidget {
  const OfflineLoader({Key? key}) : super(key: key);

  @override
  State<OfflineLoader> createState() => _OfflineLoaderState();
}

class _OfflineLoaderState extends State<OfflineLoader> {
  Timer? timer;
  bool isOffline = false;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await checkConnectivityState();
    });
  }

  Future<void> checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      debugPrint('Connected to a Wi-Fi network');
      // provider.isOffline = false;
    } else if (result == ConnectivityResult.mobile) {
      debugPrint('Connected to a mobile network');
      // provider.isOffline = false;
    } else {
      debugPrint('Not connected to any network');
      setState(() {
        isOffline = true;
      });
      // provider.isOffline = true;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOffline
        ? Material(
            child: Container(
              padding: const EdgeInsets.all(100),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                    'You\'re Offline, Please Refresh once you\'r back online.'),
              ),
            ),
          )
        : p.MultiProvider(
            providers: [
              p.ChangeNotifierProvider(
                create: (context) => InternetProvider(),
              ),
            ],
            child: const ProviderScope(
              child: MultiUserTextEditor(),
            ),
          );
  }
}
