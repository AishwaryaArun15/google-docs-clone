import 'package:docs_clone/common/colors.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errModel = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errModel.error.isEmpty) {
      ref.read(userProvider.notifier).update((state) => errModel.data);
      navigator.replace('/');
    } else {
      print(errModel.error.toString());

      sMessenger.showSnackBar(SnackBar(content: Text(errModel.error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset(
            'assets/images/google-logo.png',
            height: 30,
          ),
          label: const Text(
            'SignIn with Google',
            style: TextStyle(color: tBlackColor),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: tWhiteColor, minimumSize: const Size(150, 50)),
        ),
      ),
    );
  }
}
