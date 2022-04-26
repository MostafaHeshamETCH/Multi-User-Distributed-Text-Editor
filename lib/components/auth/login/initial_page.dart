import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../app/constants.dart';
import 'login_controller.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _InitialPage(),
      ),
    );
  }
}

class _InitialPage extends ConsumerStatefulWidget {
  const _InitialPage({Key? key}) : super(key: key);

  @override
  ConsumerState<_InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends ConsumerState<_InitialPage> {
  Future<void> _signIn() async {
    await ref.read(LoginController.notifier).createSession(
          email: 'test3@test.com',
          password: '12345678',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          height: 60,
          width: MediaQuery.of(context).size.width - (2.5 * 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.20),
                blurRadius: 22.0,
                offset: const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child: const Text(
            'Create Session',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onPressed: _signIn,
      ),
    );
  }
}
